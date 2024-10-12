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
            ForEach(trip.activities ?? []) { activity in
                NavigationLink(destination: ActivityDetailView(activity: activity)) {
                    ActivityCellView(activity: activity)
                }
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    if let activity = trip.activities?[index] {
                        viewModel.deleteActivity(from: trip, activity: activity)
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
}
