//
//  TripViewModel.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import Foundation

class TripViewModel: ObservableObject {
    @Published var trips: [Trip] = []

    let mockTrip = Trip(
        id: UUID(),
        name: "Summer Vacation in Italy",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
        country: "Italy"
    )

    private let fileName = "trips.json"

    init() {
        loadTrips()
        trips.append(mockTrip)
    }

    func addTrip(name: String, country: String, startDate: Date, endDate: Date) {
        let newTrip = Trip(id: UUID(), name: name, startDate: startDate, endDate: endDate, country: country)
        trips.append(newTrip)
        saveTrips()
    }

    func saveTrips() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let encoded = try? encoder.encode(trips) {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try encoded.write(to: url)
            } catch {
                print("Failed to save trips: \(error.localizedDescription)")
            }
        }
    }

    func loadTrips() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode([Trip].self, from: data) {
                trips = decoded
            }
        }
    }

    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "/")
    }
}
