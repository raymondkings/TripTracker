//
//  CreateTrip.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//
import AlertToast
import SwiftUI

struct CreateEditTrip: View {
    @Bindable var viewModel: TripViewModel
    @Bindable var imageViewModel: ImageViewModel
    @Bindable var createTripViewModel = CreateTripViewModel()

    @Environment(\.presentationMode) var presentationMode

    @State private var showImageErrorAlert = false
    @Binding var showSuccessToast: Bool

    var tripToEdit: Trip?

    private var isEditing: Bool {
        return tripToEdit != nil
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    tripNameSection()
                    durationSection()
                    countrySection()
                }
                if createTripViewModel.isLoading {
                    ProgressView("Saving trip...")
                }
            }
            .navigationBarTitle(navigationTitle, displayMode: .inline)
            .navigationBarItems(leading: backButton, trailing: saveButton)
            .alert(isPresented: $showImageErrorAlert, content: imageErrorAlert)
        }
        .onAppear(perform: handleOnAppear)
    }

    private var navigationTitle: String {
        isEditing ? "Edit Trip" : "Create Trip"
    }

    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Back")
        }
    }

    private var saveButton: some View {
        Button(action: {
            Task {
                await saveTrip()
                showSuccessToast = true
            }
        }) {
            Text(isEditing ? "Save" : "Create")
        }
        .disabled(!createTripViewModel.isFormValid || createTripViewModel.isLoading)
    }

    private func imageErrorAlert() -> Alert {
        Alert(
            title: Text("Image fetch failed"),
            message: Text("Image couldn't be loaded for this destination"),
            dismissButton: .default(Text("OK"))
        )
    }

    private func successToast() -> AlertToast {
        AlertToast(type: .complete(Color.green), title: "Trip Saved!")
    }

    private func handleOnAppear() {
        if let trip = tripToEdit {
            loadTripData(trip)
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
                selection: $createTripViewModel.startDate, //start date can be anytime
                displayedComponents: .date
            )
            DatePicker(
                "End Date",
                selection: $createTripViewModel.endDate,
                in: createTripViewModel.startDate..., //end date cannot be before startDate.
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
            //reactive watcher to manage the state of the dropdown
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

            // Error handling if the user tries to input an invalid destination
            if !createTripViewModel.isValidCountry && !createTripViewModel.searchText.isEmpty {
                Text("\(createTripViewModel.searchText) is not a known destination")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    private func saveTrip() async { // This is a function for both creating a new activity and editing an existing one
        createTripViewModel.isLoading = true

        if !isEditing || (tripToEdit != nil && tripToEdit?.country != createTripViewModel.searchText) {
            do {
                try await imageViewModel.searchSinglePhoto(forCountry: createTripViewModel.searchText)
            } catch {
                showImageErrorAlert = true
                imageViewModel.imageUrl = nil
            }
        }

        if let tripToEdit = tripToEdit {
            let updatedTrip = Trip(
                id: tripToEdit.id,
                name: createTripViewModel.tripName,
                startDate: createTripViewModel.startDate,
                endDate: createTripViewModel.endDate,
                country: createTripViewModel.searchText,
                imageUrl: imageViewModel.imageUrl ?? tripToEdit.imageUrl,
                mock: tripToEdit.mock
            )
            viewModel.editTrip(updatedTrip)
            presentationMode.wrappedValue.dismiss()
        } else {
            let newTrip = Trip(
                id: UUID(), // generate the UUID of the trip
                name: createTripViewModel.tripName,
                startDate: createTripViewModel.startDate,
                endDate: createTripViewModel.endDate,
                country: createTripViewModel.searchText,
                imageUrl: imageViewModel.imageUrl
            )
            viewModel.addTrip(
                name: newTrip.name,
                country: newTrip.country,
                startDate: newTrip.startDate,
                endDate: newTrip.endDate,
                imageUrl: newTrip.imageUrl
            )
            presentationMode.wrappedValue.dismiss()
        }

        createTripViewModel.isLoading = false
        showSuccessToast = true
    }

    private func loadTripData(_ trip: Trip) {
        createTripViewModel.tripName = trip.name
        createTripViewModel.searchText = trip.country
        createTripViewModel.startDate = trip.startDate
        createTripViewModel.endDate = trip.endDate
        if let imageUrl = trip.imageUrl {
            imageViewModel.imageUrl = imageUrl
        }
    }
}
