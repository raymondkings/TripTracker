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

    let mockActivity1 = Activity(
        id: UUID(),
        name: "Visit the Vatican Museum!",
        description: "Entrance fee : 5€, opens at 7 a.m.",
        date: Date(),
        location: "Vatican Museum"
    )
    
    let mockActivity2 = Activity(
        id: UUID(),
        name: "Visit the Trevi Fountain",
        description: "Entrance fee : free, opens 24/7",
        date: Date(),
        location: "Trevi Fountain"
    )

    init() {
        activities.append(mockActivity1)
        activities.append(mockActivity2)
        logger.info("Initialized ActivityViewModel with mock activity: \(self.mockActivity1.name)")
        logger.info("Initialized ActivityViewModel with mock activity: \(self.mockActivity2.name)")
    }
}
