//
//  TransportOption.swift
//  trip-tracker
//
//  Created by Raymond King on 29.03.25.
//

import Foundation
import MapKit

struct TransportOption: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let systemImage: String
    let rawType: UInt

    var type: MKDirectionsTransportType {
        MKDirectionsTransportType(rawValue: rawType)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rawType)
    }

    static func == (lhs: TransportOption, rhs: TransportOption) -> Bool {
        lhs.rawType == rhs.rawType
    }
}
