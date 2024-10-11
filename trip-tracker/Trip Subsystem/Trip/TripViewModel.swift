//
//  TripViewModel.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import Foundation

@Observable class TripViewModel {
    var trips: [Trip] = []

    let mockTrip = Trip(
        id: UUID(),
        name: "Summer Vacation in Italy",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
        country: "Italy"
    )

    private let fileName = "trips.json"

    init() {
        trips.append(mockTrip)
    }

    func addTrip(name: String, country: String, startDate: Date, endDate: Date) {
        let newTrip = Trip(id: UUID(), name: name, startDate: startDate, endDate: endDate, country: country)
        trips.append(newTrip)
    }
}
