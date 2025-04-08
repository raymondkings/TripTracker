//
//  GeminiTripRequest.swift
//  trip-tracker
//
//  Created by Raymond King on 29.03.25.
//


struct GeminiTripRequest: Codable {
    let country: String
    let cities: [String]
    let startDate: String
    let endDate: String
    let tripStyle: [String]
    let interests: [String]
    let pace: String
    let budgetPerDay: Int
    let dietaryRestrictions: [String]
    let accessibilityNeeds: String
}
