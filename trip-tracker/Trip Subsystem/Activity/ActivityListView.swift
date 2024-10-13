//
//  ActivityListView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//

import SwiftUI

struct ActivityListView: View {
    @Bindable var viewModel: TripViewModel
    var trip: Trip
    @State private var isShowingCreateActivity = false

    var body: some View {
        List {
            ForEach(groupedActivitiesByDate(), id: \.key) { date, activities in
                Section(header: Text(formattedDate(date))) {
                    ForEach(activities) { activity in
                        ActivityCellView(activity: activity)
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            let activity = activities[index]
                            viewModel.deleteActivity(from: trip, activity: activity)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationBarItems(
            trailing: Button(action: {
                isShowingCreateActivity = true
            }) {
                Image(systemName: "plus")
            }
        )
        .sheet(isPresented: $isShowingCreateActivity) {
            CreateEditActivity(viewModel: viewModel, trip: trip)
        }
    }

    private func groupedActivitiesByDate() -> [(key: Date, value: [Activity])] {
        let activities = trip.activities ?? []
        let grouped = Dictionary(grouping: activities) { activity -> Date in
            Calendar.current.startOfDay(for: activity.date)
        }
        return grouped.sorted { $0.key < $1.key }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
