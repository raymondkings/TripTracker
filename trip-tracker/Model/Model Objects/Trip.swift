//
//  Trip.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import Foundation

public struct Trip: Identifiable, Codable {
    public var id: UUID
    public var name: String
    public var startDate: Date
    public var endDate: Date
    public var country: String
    public var imageUrl: URL?
    var mock: Bool?
}
