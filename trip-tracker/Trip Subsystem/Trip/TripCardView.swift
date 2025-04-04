//
//  TripCardView.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import SwiftUI

struct TripCardView: View {
    var trip: Trip
    var imageUrl: URL?
    let onDelete: () -> Void
    var viewModel: TripViewModel

    @State private var isShowingEditTrip = false
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingShareSheet = false
    @State private var shareableFile: ShareFile?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                imageGroup

                if trip.aiGenerated {
                    Text("AI Generated")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding([.top, .trailing], 8)
                }
            }
            textGroup
        }
        .frame(width: UIScreen.main.bounds.width - 32, height: 250)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
        .contextMenu {
            Button(action: {
                isShowingEditTrip.toggle()
            }) {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive, action: {
                isShowingDeleteConfirmation = true
            }) {
                Label("Delete", systemImage: "trash")
            }

            Button(action: shareTripAsFile) {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $isShowingEditTrip) {
            CreateEditTrip(
                viewModel: viewModel,
                imageViewModel: ImageViewModel(),
                showSuccessToast: .constant(false),
                tripToEdit: trip
            )
        }
        .sheet(item: $shareableFile) { shareFile in
            ActivityView(activityItems: [shareFile.url])
        }
        .alert(isPresented: $isShowingDeleteConfirmation) {
            Alert(
                title: Text("Delete Trip"),
                message: Text("Are you sure you want to delete \"\(trip.name)\"?"),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete()
                },
                secondaryButton: .cancel()
            )
        }
        .padding(.horizontal)
    }

    private func shareTripAsFile() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                encoder.dateEncodingStrategy = .iso8601
                
                let data = try encoder.encode(trip)
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = trip.name
                    .replacingOccurrences(of: " ", with: "_")
                    + "_trip.json"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                try data.write(to: fileURL)
                
                DispatchQueue.main.async {
                    shareableFile = ShareFile(url: fileURL)
                }
            } catch {
                print("Failed to create shareable trip file:", error.localizedDescription)
                DispatchQueue.main.async {
                    shareableFile = nil
                }
            }
        }
    }

    var imageGroup: some View {
        if let localImageFilename = trip.localImageFilename {
            let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(localImageFilename)

            return AnyView(
                Image(uiImage: UIImage(contentsOfFile: localURL.path) ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
            )
        } else if let imageUrl = imageUrl {
            return AnyView(
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                } placeholder: {
                    Color.gray
                        .frame(height: 150)
                }
            )
        } else if trip.mock == true {
            return AnyView(
                Image("Rome")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipped()
            )
        } else {
            return AnyView(
                Color.gray
                    .frame(height: 150)
            )
        }
    }

    var textGroup: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(trip.name)
                .font(Font.custom("Onest-Bold", size: 18))
                .foregroundColor(Color.primary)
                .lineLimit(2)

            HStack {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(trip.country)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            HStack(spacing: 16) {
                Text("From: \(trip.startDate, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)

                Text("To: \(trip.endDate, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(duration)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(height: 100)
    }

    var duration: String {
        let componentsFormatter = DateComponentsFormatter()
        componentsFormatter.unitsStyle = .short
        componentsFormatter.allowedUnits = [.day]
        return componentsFormatter.string(from: trip.startDate, to: trip.endDate) ?? "N/A"
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
