//
//  GenerateTripWithAI.swift
//  trip-tracker
//
//  Created by Raymond King on 28.03.25.

import SwiftUI

struct GenerateTripWithAI: View {
    @State private var createTripViewModel = CreateTripViewModel()
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
                        .frame(height: 150)
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

        let payload: [String: Any] = [
            "country": createTripViewModel.searchText,
            "cities": cities.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "startDate": iso8601Date(from: startDate),
            "endDate": iso8601Date(from: endDate),
            "tripStyle": selectedStyles.map { $0.rawValue },
            "interests": selectedInterests.map { $0.rawValue },
            "pace": tripPace.rawValue,
            "budgetPerDay": Int(budgetPerDay),
            "dietaryRestrictions": selectedDietaryRestrictions.map { $0.rawValue },
            "accessibilityNeeds": accessibilityNeeds
        ]

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                self.generatedJSON = jsonString
            } else {
                self.generatedJSON = "{ \"error\": \"Failed to serialize JSON\" }"
            }
            self.isSubmitting = false
        }
    }

    private func iso8601Date(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
}
