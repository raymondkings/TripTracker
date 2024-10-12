//
//  AcitivityCellView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//

import SwiftUI

struct ActivityCellView: View {
    var activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(activity.name)
                .font(.headline)
                .foregroundColor(.primary)

            Text(activity.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Image(systemName: "calendar")
                Text("Date: \(activity.date, formatter: dateFormatter)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: "location")
                Text("Lat: \(activity.latitude.formatted()), Lon: \(activity.longitude.formatted())")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

#Preview {
    let newActivity = Activity(
        id: UUID(),
        name: "Test Activity",
        description: "This is just a mocked activity",
        date: Date(),
        latitude: 10.0,
        longitude: 11.0
    )
    ActivityCellView(activity: newActivity)
}
