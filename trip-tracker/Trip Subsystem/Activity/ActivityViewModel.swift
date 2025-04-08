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
    var mockActivities1: [Activity] = []
    var mockActivities2: [Activity] = []
    
    let mockActivity1 = Activity(
        id: UUID(),
        name: "Visit the Vatican Museum!",
        description: "Entrance fee : 5€, opens at 7 a.m.",
        date: Date(),
        location: "Vatican Museum",
        type: ActivityType.activity
    )
    
    let mockActivity2 = Activity(
        id: UUID(),
        name: "Visit the Trevi Fountain",
        description: "Entrance fee : free, opens 24/7",
        date: Date(),
        location: "Trevi Fountain",
        type: ActivityType.activity
    )
    
    let mockActivity3 = Activity(
        id: UUID(),
        name: "Hotel Indonesia Kempinski Jakarta",
        description: "Stay at this luxurious hotel in the heart of Jakarta",
        date: Date(),
        location: "Hotel Indonesia Kempinski Jakarta",
        type: ActivityType.accommodation
    )
    
    let mockActivity4 = Activity(
        id: UUID(),
        name: "Breakfast at Hotel Indonesia Kempinski Jakarta",
        description: "Enjoy a delicious breakfast buffet at your hotel",
        date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
        location: "Hotel Indonesia Kempinski Jakarta",
        type: ActivityType.restaurant,
        mealType: MealType.breakfast
    )
    
    let mockActivity5 = Activity(
        id: UUID(),
        name: "Visit the National Museum of Indonesia",
        description: "Explore Indonesian history and culture through a vast collection of artifacts",
        date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
        location: "National Museum of Indonesia Jakarta",
        type: ActivityType.activity
    )
    
    let mockActivity6 = Activity(
        id: UUID(),
        name: "Lunch at Tugu Kunstkring Paleis",
        description: "Enjoy a variety of Indonesian dishes",
        date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
        location: "Tugu Kunstkring Paleis Jakarta",
        type: ActivityType.restaurant,
        mealType: MealType.lunch
    )
    
    let mockActivity7 = Activity(
        id: UUID(),
        name: "Explore Kota Tua",
        description: "Wander through the historic old town, visiting colonial buildings and museums",
        date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
        location: "Kota Tua Jakarta",
        type: ActivityType.activity
    )
    
    let mockActivity8 = Activity(
        id: UUID(),
        name: "Dinner at Cafe Batavia",
        description: "Enjoy dinner in a historic building with a charming atmosphere",
        date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
        location: "Cafe Batavia Jakarta",
        type: ActivityType.restaurant,
        mealType: MealType.dinner
    )

    init() {
        /*
        activities.append(mockActivity1)
        activities.append(mockActivity2)
        activities.append(mockActivity3)
        activities.append(mockActivity4)
        activities.append(mockActivity5)
        activities.append(mockActivity6)
        activities.append(mockActivity7)
        activities.append(mockActivity8)

        // Group them for use in trips
        mockActivities1 = [mockActivity1, mockActivity2]
        mockActivities2 = [
            mockActivity3,
            mockActivity4,
            mockActivity5,
            mockActivity6,
            mockActivity7,
            mockActivity8
        ]
        logger.info("Initialized ActivityViewModel with mock activity: \(self.mockActivity1.name)")
        logger.info("Initialized ActivityViewModel with mock activity: \(self.mockActivity2.name)")
         */
    }
}
