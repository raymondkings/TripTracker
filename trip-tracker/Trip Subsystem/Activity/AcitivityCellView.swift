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
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(activity.name)
                    .font(Font.custom("Onest-Bold", size: 18))
                    .foregroundColor(.primary)

                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
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
            }
            .padding(.vertical, 8)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .padding(.trailing)
        }
        .padding()
        .onTapGesture {
            openInAppleMaps(with: activity.location)
        }
    }

    //To properly display date
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    //This is a function to redirect to Apple Map, with the location as the search term
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
