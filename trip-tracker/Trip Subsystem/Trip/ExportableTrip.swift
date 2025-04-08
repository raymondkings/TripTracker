//
//  ExportableTrip.swift
//  trip-tracker
//
//  Created by Raymond King on 04.04.25.
//


struct ExportableTrip: Codable {
    var trip: Trip
    var imageBase64: String?
}
