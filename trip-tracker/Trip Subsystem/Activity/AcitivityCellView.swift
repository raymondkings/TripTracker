//
//  AcitivityCellView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//
import MapKit
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
                Text(activity.location)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onTapGesture {
            openInAppleMaps(with: activity.location)
        }
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private func openInAppleMaps(with searchText: String) {
        let escapedQuery = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "http://maps.apple.com/?q=\(escapedQuery)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    let newActivity = Activity(
        id: UUID(),
        name: "Test Activity",
        description: "This is a very fun activity!",
        date: Date(),
        location: "Vatican Museum"
    )
    ActivityCellView(activity: newActivity)
}
