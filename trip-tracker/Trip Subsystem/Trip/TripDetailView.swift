//
//  TripDetailView.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import SwiftUI

struct TripDetailView: View {
    var trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(trip.name)
                .font(.body)

            Text("Country: \(trip.country)")
                .font(.body)

            Text("Start Date: \(trip.startDate, formatter: dateFormatter)")
                .font(.body)

            Text("End Date: \(trip.endDate, formatter: dateFormatter)")
                .font(.body)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    TripDetailView(trip: Trip(
        id: UUID(),
        name: "Winter Getaway to Switzerland",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        country: "Switzerland"
    ))
}
