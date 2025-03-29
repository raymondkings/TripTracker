//
//  TripListView.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//
import AlertToast
import SwiftUI
import UniformTypeIdentifiers

struct TripListView: View {
    @State var viewModel = TripViewModel()
    @State private var isShowingCreateTrip = false
    @State private var isShowingGenerateTripWithAI = false
    @State private var isShowingFileImporter = false
    @State private var imageViewModel = ImageViewModel()
    @State private var showSuccessToast = false
    @State private var importErrorMessage: String?
    @State private var showErrorToast = false

    var body: some View {
        NavigationView {
            ScrollView {
                tripListContent()
            }
            .navigationTitle("Trips")
            .navigationBarItems(trailing: addButton())
            .sheet(isPresented: $isShowingCreateTrip) {
                CreateEditTrip(
                    viewModel: viewModel,
                    imageViewModel: imageViewModel,
                    showSuccessToast: $showSuccessToast
                )
            }
            .sheet(isPresented: $isShowingGenerateTripWithAI, content: {
                GenerateTripWithAI(
                    tripViewModel : viewModel
                )
            })
            .fileImporter(
                isPresented: $isShowingFileImporter,
                allowedContentTypes: [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                handleTripImport(result: result)
            }
            .toast(isPresenting: $showSuccessToast, duration: 2.0) {
                AlertToast(type: .complete(Color.green), title: "Trip Saved!")
            }
            .toast(isPresenting: $showErrorToast, duration: 2.0) {
                AlertToast(type: .error(Color.red), title: importErrorMessage ?? "Failed to import trip")
            }
        }
    }

    // MARK: - Extracted Methods

    private func tripListContent() -> some View {
        VStack(spacing: 16) {
            ForEach(viewModel.trips) { trip in
                NavigationLink(
                    destination: ActivityListView(
                        viewModel: viewModel, trip: trip
                    )
                ) {
                    TripCardView(
                        trip: trip,
                        imageUrl: trip.imageUrl,
                        onDelete: {
                            viewModel.deleteTrip(trip)
                        }, viewModel: viewModel
                    )
                }
            }
        }
        .padding(16)
    }

    private func addButton() -> some View {
        HStack {
            Menu {
                Button("Create Trip") {
                    isShowingCreateTrip = true
                }

                Button("Generate Trip with AI ✨") {
                    isShowingGenerateTripWithAI = true
                }

                Button("Import Trip") {
                    isShowingFileImporter = true
                }
            } label: {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            }
        }
    }

    private func handleTripImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let selectedURL = urls.first else { return }

            // Start accessing security-scoped resource
            guard selectedURL.startAccessingSecurityScopedResource() else {
                importErrorMessage = "Permission denied to access the file."
                showErrorToast = true
                return
            }

            defer {
                selectedURL.stopAccessingSecurityScopedResource()
            }

            do {
                let data = try Data(contentsOf: selectedURL)
                print(String(data: data, encoding: .utf8) ?? "Invalid JSON data")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                var importedTrip = try decoder.decode(Trip.self, from: data)

                importedTrip.id = UUID() // Prevent conflict with existing UUID
                importedTrip.mock = false

                viewModel.trips.append(importedTrip)
                showSuccessToast = true
            } catch {
                importErrorMessage = "Failed to decode trip JSON"
                showErrorToast = true
                print("Failed to import trip:", error.localizedDescription)
            }

        case .failure(let error):
            importErrorMessage = error.localizedDescription
            showErrorToast = true
            print("File import failed:", error.localizedDescription)
        }
    }
}

//#Preview {
//    TripListView()
//}
