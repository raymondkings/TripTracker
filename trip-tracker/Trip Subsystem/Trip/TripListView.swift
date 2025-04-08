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

    /// Limit the usage for generating trip with AI
    @State private var dailyGenerationCount = 0
    @State private var lastGenerationDate: Date?
    let dailyLimit = 3


    var body: some View {
        NavigationStack {
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
                    tripViewModel : viewModel,
                    isShowingGenerateTripWithAI: $isShowingGenerateTripWithAI
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
        .onAppear {
            loadGenerationLimit()
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
                    incrementGenerationCount()
                }
                .disabled(dailyGenerationCount >= dailyLimit)

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
    
    private func loadGenerationLimit() {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())

        if let savedDate = defaults.object(forKey: "lastGenerationDate") as? Date,
           Calendar.current.isDate(savedDate, inSameDayAs: today) {
            dailyGenerationCount = defaults.integer(forKey: "generationCount")
        } else {
            // New day
            defaults.set(today, forKey: "lastGenerationDate")
            defaults.set(0, forKey: "generationCount")
            dailyGenerationCount = 0
        }

        lastGenerationDate = today
    }

    private func incrementGenerationCount() {
        dailyGenerationCount += 1
        UserDefaults.standard.set(dailyGenerationCount, forKey: "generationCount")
    }


    private func handleTripImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let selectedURL = urls.first else { return }

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
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                var exportable = try decoder.decode(ExportableTrip.self, from: data)

                // Decode image and save it locally
                var localImageFilename: String? = nil
                if let base64 = exportable.imageBase64,
                   let imageData = Data(base64Encoded: base64) {
                    let filename = UUID().uuidString + ".jpg"
                    let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        .appendingPathComponent(filename)
                    try imageData.write(to: imageURL)
                    localImageFilename = filename
                }

                // Finalize the trip
                var importedTrip = exportable.trip
                importedTrip.id = UUID()
                importedTrip.mock = false
                importedTrip.localImageFilename = localImageFilename

                viewModel.trips.append(importedTrip)
                showSuccessToast = true
            } catch {
                importErrorMessage = "Failed to import trip JSON"
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
