//
//  TripViewModel.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import Foundation

@Observable class TripViewModel {
    var trips: [Trip] = []

    init() {
        let mockTrip = Trip(
            id: UUID(),
            name: "Summer Vacation in Italy",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
            country: "Italy",
            imageUrl: nil,
            mock: true,
            activities: []
        )
        trips.append(mockTrip)
    }

    func addTrip(
        name: String,
        country: String,
        startDate: Date,
        endDate: Date,
        imageUrl: URL?
    ) {
        let newTrip = Trip(
            id: UUID(),
            name: name,
            startDate: startDate,
            endDate: endDate,
            country: country,
            imageUrl: imageUrl,
            activities: []
        )
        trips.append(newTrip)
    }

    func editTrip(_ updatedTrip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == updatedTrip.id }) {
            trips[index] = updatedTrip
        }
    }

    func deleteTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips.remove(at: index)
        }
    }

    func addActivity(to trip: Trip, activity: Activity) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index].activities?.append(activity)
        }
    }

    func deleteActivity(from trip: Trip, activity: Activity) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index].activities?.removeAll { $0.id == activity.id }
        }
    }

    func editActivity(from trip: Trip, activity: Activity) {
        if let tripIndex = trips.firstIndex(where: { $0.id == trip.id }),
           let activityIndex = trips[tripIndex].activities?.firstIndex(where: { $0.id == activity.id })
        { trips[tripIndex].activities?[activityIndex] = activity
        }
    }
}
