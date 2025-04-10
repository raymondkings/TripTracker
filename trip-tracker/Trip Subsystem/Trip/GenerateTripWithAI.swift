//
//  GenerateTripWithAI.swift
//  trip-tracker
//
//  Created by Raymond King on 28.03.25.

import SwiftUI
import AlertToast

struct GenerateTripWithAI: View {
    @State private var createTripViewModel = CreateTripViewModel()
    @Bindable var tripViewModel: TripViewModel
    @Binding var isShowingGenerateTripWithAI: Bool
    @State private var cities: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    @State private var selectedStyles: Set<TripStyle> = []
    @State private var selectedInterests: Set<Interest> = []
    @State private var selectedDietaryRestrictions: Set<DietaryRestriction> = []
    @State private var accessibilityNeeds: String = ""

    @State private var tripPace: TripPace = .balanced
    @State private var budgetPerDay: Double = 150.0

    @State private var isSubmitting = false
    @State private var generatedJSON: String = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    
    @Binding var showSuccessToast: Bool
    @Binding var showErrorToastAITrip: Bool

    /// Limit the usage for generating trip with AI
    @Binding var dailyGenerationCount: Int


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Destination")) {
                    TextField(
                        "Search destination",
                        text: $createTripViewModel.searchText,
                        onEditingChanged: createTripViewModel.handleEditingChanged
                    )

                    .onChange(of: createTripViewModel.searchText) {
                        createTripViewModel.validateCountry( createTripViewModel.searchText)
                    }
                    .multilineTextAlignment(.leading)

                    if createTripViewModel.isShowingDropdown && !createTripViewModel.filteredCountries.isEmpty {
                        List(createTripViewModel.filteredCountries.prefix(10), id: \ .self) { country in
                            Button(action: {
                                createTripViewModel.selectCountry(country)
                            }) {
                                Text(country)
                            }
                        }
                        .frame(height: 20)
                    }

                    if !createTripViewModel.isValidCountry && !createTripViewModel.searchText.isEmpty {
                        Text("\(createTripViewModel.searchText) is not a known destination")
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    TextField("Cities to Visit (comma-separated)", text: $cities)
                }

                Section(header: Text("Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                }

                Section(header: Text("Trip Style")) {
                    multiSelectChips(options: TripStyle.allCases, selected: $selectedStyles)
                }

                Section(header: Text("Interests")) {
                    multiSelectChips(options: Interest.allCases, selected: $selectedInterests)
                }

                Section(header: Text("Trip Pace")) {
                    Picker("Select Pace", selection: $tripPace) {
                        ForEach(TripPace.allCases) { pace in
                            Text(pace.id).tag(pace)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Budget per Day: €\(Int(budgetPerDay))")) {
                    Slider(value: $budgetPerDay, in: 50...500, step: 10)
                }

                Section(header: Text("Special Requests")) {
                    VStack(alignment: .leading) {
                        Text("Dietary Restrictions")
                        multiSelectChips(options: DietaryRestriction.allCases, selected: $selectedDietaryRestrictions)

                        TextField("Accessibility Needs", text: $accessibilityNeeds)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(12)
                        .padding()
                }

                Button("Choose Cover Image") {
                    isShowingImagePicker = true
                }
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }

                Section {
                    Button(action: generateTripWithAI) {
                        if isSubmitting {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                    Text("Generating Trip")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                            Text("Generate Trip")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSubmitting || createTripViewModel.searchText.isEmpty || !createTripViewModel.isValidCountry)
                }
            }
            .navigationTitle("Generate Trip with AI ✨")
            .toast(isPresenting: $showErrorToastAITrip, duration: 2.0) {
                AlertToast(type: .error(Color.red), title: "Failed to generate trip, please try again later")
            }
        }
        .interactiveDismissDisabled(isSubmitting)
    }
    
    private func incrementGenerationCount() {
        dailyGenerationCount += 1
        UserDefaults.standard.set(dailyGenerationCount, forKey: "generationCount")
    }

    private func multiSelectChips<T: Hashable & Identifiable & RawRepresentable>(options: [T], selected: Binding<Set<T>>) -> some View where T.RawValue == String {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(options) { option in
                    let isSelected = selected.wrappedValue.contains(option)
                    Text(option.rawValue.capitalized)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(isSelected ? .white : .primary)
                        .clipShape(Capsule())
                        .onTapGesture {
                            if isSelected {
                                selected.wrappedValue.remove(option)
                            } else {
                                selected.wrappedValue.insert(option)
                            }
                        }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func saveImageLocally(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            print("Failed to save image locally:", error)
            return nil
        }
    }

    private func generateTripWithAI() {
        isSubmitting = true

        let request = GeminiTripRequest(
            country: createTripViewModel.searchText,
            cities: cities.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            startDate: iso8601Date(from: startDate),
            endDate: iso8601Date(from: endDate),
            tripStyle: selectedStyles.map { $0.rawValue },
            interests: selectedInterests.map { $0.rawValue },
            pace: tripPace.rawValue,
            budgetPerDay: Int(budgetPerDay),
            dietaryRestrictions: selectedDietaryRestrictions.map { $0.rawValue },
            accessibilityNeeds: accessibilityNeeds
        )

        let apiKey = ConfigTemplate.geminiAPIKey

        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=\(apiKey)") else {
            isSubmitting = false
            generatedJSON = "{ \"error\": \"Invalid URL.\" }"
            showErrorToastAITrip = true
            return
        }

        let prompt = """
        You are a travel assistant. Generate a trip in valid JSON that can be parsed directly into the following Swift types:

        Trip:
        - id: UUID (as a string)
        - name: String
        - startDate: ISO8601 Date String
        - endDate: ISO8601 Date String
        - country: String
        - imageUrl: URL (optional)
        - activities: [Activity]
        - mock: Bool (optional)
        - aiGenerated: Bool (optional)

        Activity:
        - id: UUID (as a string)
        - name: String
        - description: String
        - date: ISO8601 Date String
        - location: String
        - type: Enum (activity, accommodation, restaurant)
        - mealType: Enum (optional, one of breakfast, lunch, dinner, multiple)
        
        ### HARD RULES — DO NOT VIOLATE:

        1. Return an itinerary for **EVERY DAY** between `startDate` and `endDate`, inclusive.
        2. Each day **must contain exactly 3 meals**: breakfast, lunch, and dinner — always in this order.
        3. You can add **0 to 3 activities per day** — placed **before lunch, between meals, or after dinner**. Do not place any activities before breakfast.
        4. The mealType order must always be:
           - breakfast → activity (optional)
           - lunch → activity (optional)
           - dinner → activity (optional)
        5. One accommodation per day (type = accommodation), ideally placed at the end of the day.
        6. Ensure that activities are realistic, related to the cities given, and include interesting cultural, historical, or fun local experiences.
        7. The location name should match the name of the place, the exact address is not needed. Append the city name behind the location name. 
        8. Ensure all fields match exactly and enums are in lowercase string format. Output **ONLY valid JSON** — no markdown, no extra text, and no code blocks.

        ---

        ### Example Day Order (suggested pattern):

        - breakfast (restaurant)
        - activity (e.g., museum)
        - lunch (restaurant)
        - activity (e.g., walking tour)
        - dinner (restaurant)
        - accommodation
        
        Input: \(request)
        """

        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            isSubmitting = false
            generatedJSON = "{ \"error\": \"Failed to encode request body.\" }"
            showErrorToastAITrip = true
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, _, error in
            DispatchQueue.main.async {
                defer {
                    isSubmitting = false
                }

                guard let data = data else {
                    generatedJSON = "{ \"error\": \"No response data from Gemini.\" }"
                    showErrorToastAITrip = true
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let content = candidates.first?["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    let cleanText = text
                        .replacingOccurrences(of: "```json", with: "")
                        .replacingOccurrences(of: "```", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    guard let jsonData = cleanText.data(using: .utf8) else {
                        generatedJSON = "{ \"error\": \"Failed to convert Gemini response to data.\" }"
                        showErrorToastAITrip = true
                        return
                    }

                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        var decodedTrip = try decoder.decode(Trip.self, from: jsonData)
                        decodedTrip.id = UUID()
                        decodedTrip.aiGenerated = true
                        decodedTrip.mock = true

                        let localImageFilename = selectedImage.flatMap { saveImageLocally($0) }
                        decodedTrip.localImageFilename = localImageFilename

                        tripViewModel.addAIGeneratedTrip(decodedTrip)
                        incrementGenerationCount()
                        showSuccessToast = true
                        isShowingGenerateTripWithAI = false
                    } catch {
                        print("Decoding error:", error)
                        generatedJSON = "{ \"error\": \"Failed to decode AI trip: \(error.localizedDescription)\" }"
                        showErrorToastAITrip = true
                    }
                } else {
                    generatedJSON = "{ \"error\": \"Unexpected Gemini response format.\" }"
                    showErrorToastAITrip = true
                }
            }
        }
        .resume()
    }


    private func iso8601Date(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
}
