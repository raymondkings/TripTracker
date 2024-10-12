//
//  CreateTrip.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//
import SwiftUI

struct CreateTrip: View {
    @Bindable var viewModel: TripViewModel
    @Bindable var imageViewModel: ImageViewModel
    @Bindable var createTripViewModel = CreateTripViewModel()

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    tripNameSection()
                    durationSection()
                    countrySection()
                }
                if createTripViewModel.isLoading {
                    ProgressView("Creating trip...")
                }
            }
            .navigationBarTitle("Create Trip", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back")
                },
                trailing: Button(action: {
                    Task {
                        await createTrip()
                    }
                }) {
                    Text("Create")
                }
                .disabled(!createTripViewModel.isFormValid || createTripViewModel.isLoading)
            )
        }
        .onChange(of: createTripViewModel.searchText) {
            createTripViewModel.validateCountry()
        }
    }

    private func tripNameSection() -> some View {
        Section(header: Text("Trip Name")) {
            TextField("Enter trip name", text: $createTripViewModel.tripName)
                .onChange(of: createTripViewModel.tripName) { _, newValue in
                    createTripViewModel.isTripNameValid = !newValue.isEmpty
                }

            if !createTripViewModel.isTripNameValid && createTripViewModel.tripName.isEmpty {
                Text("Trip name cannot be empty")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    private func durationSection() -> some View {
        Section(header: Text("Duration")) {
            DatePicker(
                "Start Date",
                selection: $createTripViewModel.startDate,
                in: Date()...,
                displayedComponents: .date
            )
            DatePicker(
                "End Date",
                selection: $createTripViewModel.endDate,
                in: createTripViewModel.startDate...,
                displayedComponents: .date
            )
        }
    }

    private func countrySection() -> some View {
        Section(header: Text("Destination")) {
            TextField(
                "Search destination",
                text: $createTripViewModel.searchText,
                onEditingChanged: createTripViewModel.handleEditingChanged
            )
            .onChange(of: createTripViewModel.searchText) { _, newValue in
                createTripViewModel.isShowingDropdown =
                    !newValue.isEmpty && !createTripViewModel.countries.contains(newValue)
            }
            if createTripViewModel.isShowingDropdown && !createTripViewModel.filteredCountries.isEmpty {
                List(createTripViewModel.filteredCountries.prefix(10), id: \.self) { country in
                    Button(action: {
                        createTripViewModel.selectCountry(country)
                    }) {
                        Text(country)
                    }
                }
                .frame(height: 25)
            }

            if !createTripViewModel.isValidCountry && !createTripViewModel.searchText.isEmpty {
                Text("\(createTripViewModel.searchText) is not a known destination")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    private func createTrip() async {
        createTripViewModel.isLoading = true
        await imageViewModel.searchSinglePhoto(forCountry: createTripViewModel.searchText)

        if let imageUrl = imageViewModel.imageUrl {
            viewModel.addTrip(
                name: createTripViewModel.tripName,
                country: createTripViewModel.searchText,
                startDate: createTripViewModel.startDate,
                endDate: createTripViewModel.endDate,
                imageUrl: imageUrl
            )
            presentationMode.wrappedValue.dismiss()
        }

        createTripViewModel.isLoading = false
    }
}
