//
//  TripCardView.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import SwiftUI

struct TripCardView: View {
    var trip: Trip

    var body: some View {
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
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue)
        .cornerRadius(25)
        .shadow(radius: 5)
        .padding(.horizontal, 16)
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
