//
//  ActivityViewModel.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//

import Foundation
import os

@Observable class ActivityViewModel {
    private let logger = Logger(subsystem: "trip-tracker", category: "ActivityViewModel")
    var activities: [Activity] = []

    let mockActivity = Activity(
        id: UUID(),
        name: "Visit the Vatican Museum!",
        description: "Entrance fee : 5€, opens at 7 a.m.",
        date: Date(),
        location: "Vatican Museum"
    )

    init() {
        activities.append(mockActivity)
        logger.info("Initialized ActivityViewModel with mock activity: \(self.mockActivity.name)")
    }
}
