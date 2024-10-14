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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageGroup
            textGroup
        }
        .frame(width: UIScreen.main.bounds.width - 32, height: 250)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "Trash")
            }
        }
        .padding(.horizontal)
    }

    var imageGroup: some View {
        if trip.mock == true && imageUrl == nil {
            return AnyView(
                Image("Rome")
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
                .font(.headline)
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

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
