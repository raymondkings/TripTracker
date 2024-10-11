//
//  TripViewModel.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import Foundation

@Observable class TripViewModel {
    var trips: [Trip] = []
    let mockImageUrlString = "https://api.unsplash.com/photos/random?client_id=nVxMNJF2r7WBgA7eDhJKkTFXe--PLpXh6lGUSDLgs0&query=famous tourist attractions in italy"

    private let fileName = "trips.json"

    init() {
        let mockTrip = Trip(
            id: UUID(),
            name: "Summer Vacation in Italy",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
            country: "Italy",
            imageUrl: nil
        )
        trips.append(mockTrip)
    }

    func addTrip(name: String, country: String, startDate: Date, endDate: Date, imageUrl: URL?) {
        let newTrip = Trip(id: UUID(), name: name, startDate: startDate,
                           endDate: endDate, country: country, imageUrl: imageUrl)
        trips.append(newTrip)
    }
}
