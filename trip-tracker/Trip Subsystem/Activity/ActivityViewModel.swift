//
//  ActivityViewModel.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//

import Foundation

@Observable class ActivityViewModel {
    var activities: [Activity] = []

    let mockActivity = Activity(
        id: UUID(),
        name: "Visit the Vatican Museum!",
        description: "blablablablablablablablablablablablablablablablablablablablabla",
        date: Date(),
        latitude: 41.902916,
        longitude: 12.453389
    )

    init() {
        activities.append(mockActivity)
    }

    func addActivity(name: String, description: String, date: Date, latitude: Double, longitude: Double) {
        let newActivity = Activity(
            id: UUID(),
            name: name,
            description: description,
            date: date,
            latitude: latitude,
            longitude: longitude
        )
        activities.append(newActivity)
    }

    func editActivity(_ updatedActivity: Activity) {
        if let index = activities.firstIndex(where: { $0.id == updatedActivity.id }) {
            activities[index] = updatedActivity
        }
    }

    func deleteActivity(_ activity: Activity) {
        if let index = activities.firstIndex(where: { $0.id == activity.id }) {
            activities.remove(at: index)
        }
    }
}
