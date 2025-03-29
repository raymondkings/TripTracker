//
//  Trip.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//
import Foundation

public enum TripStyle: String, CaseIterable, Identifiable {
    case adventure, relaxation, culture, foodie, nature, shopping
    public var id: String { rawValue.capitalized }
}

public enum Interest: String, CaseIterable, Identifiable {
    case museums, hiking, beaches, nightlife
    public var id: String { rawValue.capitalized }
}

public enum DietaryRestriction: String, CaseIterable, Identifiable {
    case vegetarian, halal, glutenFree
    public var id: String { rawValue.capitalized }
}

public enum TripPace: String, CaseIterable, Identifiable {
    case relaxed, balanced, packed
    public var id: String { rawValue.capitalized }
}


public struct Trip: Identifiable, Codable {
    public var id: UUID
    public var name: String
    public var startDate: Date
    public var endDate: Date
    public var country: String
    public var imageUrl: URL?
    var mock: Bool = false
    public var activities: [Activity] = []
}
