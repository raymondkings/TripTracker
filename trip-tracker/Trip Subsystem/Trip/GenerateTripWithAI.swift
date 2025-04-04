//
//  GenerateTripWithAI.swift
//  trip-tracker
//
//  Created by Raymond King on 28.03.25.

import SwiftUI

struct GenerateTripWithAI: View {
    @State private var createTripViewModel = CreateTripViewModel()
    @Bindable var tripViewModel: TripViewModel
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

                Section {
                    Button(action: generateTripWithAI) {
                        if isSubmitting {
                            ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Generate Trip")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSubmitting || createTripViewModel.searchText.isEmpty || !createTripViewModel.isValidCountry)
                }

                if !generatedJSON.isEmpty {
                    Section(header: Text("Generated Trip JSON")) {
                        ScrollView {
                            Text(generatedJSON)
                                .font(.system(.footnote, design: .monospaced))
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Generate Trip with AI ✨")
        }
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
            generatedJSON = "{ \"error\": \"Invalid URL.\" }"
            isSubmitting = false
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

        The Location of an Activity has to be an exact location since it is an input for Map.
        Also give the name of the hotel as accomodations. You do not need to consider the modes of transportation, so you also do not need to consider arrival and departure. One full day should have 3 meals : breakfast, lunch, and dinner. Since the first day is arrival day and the last day is departure day, the first day should only have dinner, and the last day should only have breakfast.   Ensure all fields match exactly and enums are in lowercase string format. Output ONLY valid JSON — no Markdown or code blocks.
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
            generatedJSON = "{ \"error\": \"Failed to encode request body.\" }"
            isSubmitting = false
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    print("Raw Gemini response:\n", String(data: data, encoding: .utf8) ?? "N/A")

                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let content = candidates.first?["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let text = parts.first?["text"] as? String {
                        print("Gemini parsed text:\n\(text)")
                        let cleanText = text
                            .replacingOccurrences(of: "```json", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)

                        if let jsonData = cleanText.data(using: .utf8) {
                            do {
                                let decoder = JSONDecoder()
                                decoder.dateDecodingStrategy = .iso8601
                                var decodedTrip = try decoder.decode(Trip.self, from: jsonData)
                                decodedTrip.id = UUID()
                                decodedTrip.aiGenerated = true
                                decodedTrip.mock = true
                                self.tripViewModel.addAIGeneratedTrip(decodedTrip)
                                self.generatedJSON = "Trip added successfully 🎉"
                            } catch {
                                print("Decoding error:", error)
                                self.generatedJSON = "{ \"error\": \"Failed to decode AI trip: \(error.localizedDescription)\" }"
                            }
                        } else {
                            self.generatedJSON = "{ \"error\": \"Failed to convert Gemini response to data.\" }"
                        }
                    } else if let jsonError = try? JSONSerialization.jsonObject(with: data, options: []) {
                        print("Unexpected JSON structure:\n\(jsonError)")
                        self.generatedJSON = "{ \"error\": \"Unexpected Gemini response format.\" }"
                    } else {
                        self.generatedJSON = "{ \"error\": \"Failed to decode Gemini response.\" }"
                    }
                }

                self.isSubmitting = false
            }
        }.resume()
    }



    private func iso8601Date(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
}
