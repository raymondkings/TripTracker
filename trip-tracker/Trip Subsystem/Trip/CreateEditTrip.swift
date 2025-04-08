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
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false

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
                .multilineTextAlignment(.leading)

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
            .onChange(of: createTripViewModel.searchText) {
                createTripViewModel.validateCountry( createTripViewModel.searchText)
            }
            .multilineTextAlignment(.leading)
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

    private func saveTrip() async {
        createTripViewModel.isLoading = true

        let localImageFilename = selectedImage.flatMap { saveImageLocally($0) }

        if let tripToEdit = tripToEdit {
            let updatedTrip = Trip(
                id: tripToEdit.id,
                name: createTripViewModel.tripName,
                startDate: createTripViewModel.startDate,
                endDate: createTripViewModel.endDate,
                country: createTripViewModel.searchText,
                imageUrl: nil,
                localImageFilename: localImageFilename ?? tripToEdit.localImageFilename,
                mock: tripToEdit.mock,
                aiGenerated: tripToEdit.aiGenerated,
                activities: tripToEdit.activities
            )
            viewModel.editTrip(updatedTrip)
        } else {
            let newTrip = Trip(
                id: UUID(),
                name: createTripViewModel.tripName,
                startDate: createTripViewModel.startDate,
                endDate: createTripViewModel.endDate,
                country: createTripViewModel.searchText,
                imageUrl: nil,
                localImageFilename: localImageFilename
            )

            viewModel.addTrip(
                name: newTrip.name,
                country: newTrip.country,
                startDate: newTrip.startDate,
                endDate: newTrip.endDate,
                imageUrl: nil,
                localImageFilename: localImageFilename
            )
        }

        createTripViewModel.isLoading = false
        showSuccessToast = true
        presentationMode.wrappedValue.dismiss()
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
