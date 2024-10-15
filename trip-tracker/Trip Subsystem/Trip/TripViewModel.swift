//
//  TripViewModel.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import Foundation
import os

@Observable class TripViewModel {
    private let logger = Logger(subsystem: "trip-tracker", category: "TripViewModel")

    var trips: [Trip] = []

    init() {
        logger.debug("Initializing TripViewModel with mock data.")
        let mockActivity = ActivityViewModel().mockActivity
        let mockTrip = Trip(
            id: UUID(),
            name: "Summer Vacation in Italy",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
            country: "Italy",
            imageUrl: nil,
            mock: true,
            activities: [mockActivity]
        )
        trips.append(mockTrip)
        logger.info("Mock trip \(mockTrip.name) added.")
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
        logger.info("New trip \(name) added for country \(country).")
    }

    func editTrip(_ updatedTrip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == updatedTrip.id }) {
            trips[index] = updatedTrip
            logger.debug("Trip \(updatedTrip.name) updated.")
        } else {
            logger.error("Failed to find trip \(updatedTrip.name) for editing.")
        }
    }

    func deleteTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips.remove(at: index)
            logger.info("Trip \(trip.name) deleted.")
        } else {
            logger.error("Failed to delete trip \(trip.name). Trip not found.")
        }
    }

    func addActivity(to trip: Trip, activity: Activity) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index].activities.append(activity)
            logger.info("Added activity \(activity.name) to trip \(trip.name).")
        } else {
            logger.error("Failed to find trip \(trip.name) for adding activity \(activity.name).")
        }
    }

    func deleteActivity(from trip: Trip, activity: Activity) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index].activities.removeAll { $0.id == activity.id }
            logger.info("Deleted activity \(activity.name) from trip \(trip.name).")
        } else {
            logger.error("Failed to find trip \(trip.name) for deleting activity \(activity.name).")
        }
    }

    func editActivity(from trip: Trip, activity: Activity) {
        if let tripIndex = trips.firstIndex(where: { $0.id == trip.id }),
           let activityIndex = trips[tripIndex].activities.firstIndex(where: { $0.id == activity.id }) {
            trips[tripIndex].activities[activityIndex] = activity
            logger.debug("Activity \(activity.name) edited in trip \(trip.name).")
        } else {
            logger.error("Failed to find trip \(trip.name) or activity \(activity.name) for editing.")
        }
    }
}
