//
//  Activity.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//
import Foundation

public enum ActivityType: String, Codable, CaseIterable {
    case activity
    case accommodation
    case restaurant
}

public enum MealType: String, Codable, CaseIterable {
    case breakfast, lunch, dinner, multiple
}

public struct Activity: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var description: String
    public var date: Date
    public var location: String
    public var type: ActivityType
    public var mealType: MealType?
}
