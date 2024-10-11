//
//  CreateTrip.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import SwiftUI

struct CreateTrip: View {
    @ObservedObject var viewModel: TripViewModel

    @State private var tripName: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var searchText: String = ""
    @State private var isShowingDropdown = false
    @State private var isTripNameValid: Bool = true

    @Environment(\.presentationMode) var presentationMode

    var isFormValid: Bool {
        !tripName.isEmpty && isValidCountry
    }

    var countries: [String] {
        let locale = Locale.current
        return Locale.Region.isoRegions.compactMap { region in locale.localizedString(forRegionCode: region.identifier)
        }
        .sorted()
    }

    var filteredCountries: [String] {
        return countries.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var isValidCountry: Bool {
        countries.contains(searchText)
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    tripNameSection()
                    durationSection()
                    countrySection()
                }
            }
            .navigationBarTitle("Create Trip", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back")
                },
                trailing: Button(action: createTrip) {
                    Text("Create")
                }
            )
        }
    }

    private func tripNameSection() -> some View {
        Section(header: Text("Trip Name")) {
            TextField("Enter trip name", text: $tripName)
                .onChange(of: tripName) { _, newValue in
                    isTripNameValid = !newValue.isEmpty
                }

            if !isTripNameValid && tripName.isEmpty {
                Text("Trip name cannot be empty")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    private func durationSection() -> some View {
        Section(header: Text("Duration")) {
            DatePicker("Start Date", selection: $startDate, in: Date()..., displayedComponents: .date)
            DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
        }
    }

    private func countrySection() -> some View {
        Section(header: Text("Country")) {
            TextField("Search country", text: $searchText, onEditingChanged: handleEditingChanged)
                .onChange(of: searchText) { _, newValue in
                    isShowingDropdown = !newValue.isEmpty
                }

            if isShowingDropdown && !filteredCountries.isEmpty {
                List(filteredCountries.prefix(10), id: \.self) { country in
                    Button(action: {
                        selectCountry(country)
                    }) {
                        Text(country)
                    }
                }
                .frame(height: 25)
            }

            if !isValidCountry && !searchText.isEmpty && filteredCountries.isEmpty {
                Text("\(searchText) is not a known country")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    private func validateTripName(_ newValue: String) {
        isTripNameValid = !newValue.isEmpty
    }

    private func filterCountries(_ newValue: String) {
        isShowingDropdown = !newValue.isEmpty
    }

    private func handleEditingChanged(_ isEditing: Bool) {
        isShowingDropdown = isEditing && !searchText.isEmpty
    }

    private func selectCountry(_ country: String) {
        searchText = country
        isShowingDropdown = false
    }

    private func createTrip() {
        if isFormValid {
            viewModel.addTrip(name: tripName, country: searchText, startDate: startDate, endDate: endDate)
            presentationMode.wrappedValue.dismiss()
        } else {
            print("Form is not valid")
        }
    }
}

#Preview {
    CreateTrip(viewModel: TripViewModel())
}
