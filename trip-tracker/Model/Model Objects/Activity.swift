//
//  Activity.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//
import Foundation

public struct Activity: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var description: String
    public var date: Date
    public var latitude: Double
    public var longitude: Double
}
