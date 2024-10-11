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

    var body: some View {
        ZStack(alignment: .leading) {
            imageGroup
            textGroup
        }
        .padding()
        .frame(maxWidth: .infinity)
        .cornerRadius(25)
        .shadow(radius: 5)
    }

    var imageGroup: some View {
        // Image Section
        if let imageUrl = imageUrl {
            return AnyView(
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .cornerRadius(10)
                        )
                } placeholder: {
                    Color.gray
                        .frame(height: 200)
                        .cornerRadius(10)
                }
            )
        } else {
            return AnyView(
                Image("Rome")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .cornerRadius(10)
                        .frame(height: 200)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            )
        }
    }

    var textGroup: some View {
        // Text Section
        VStack(alignment: .leading, spacing: 10) {
            Text(trip.name)
                .font(.headline)
                .foregroundColor(.white)
            Text(trip.country)
                .font(.subheadline)
                .foregroundColor(.white)
            Text("From: \(trip.startDate, formatter: dateFormatter)")
                .font(.caption)
                .foregroundColor(.white)
            Text("To: \(trip.endDate, formatter: dateFormatter)")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.leading, 16)
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

#Preview {
    TripCardView(trip: Trip(
        id: UUID(),
        name: "Summer Vacation in Italy",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
        country: "Italy"
    ))
}
