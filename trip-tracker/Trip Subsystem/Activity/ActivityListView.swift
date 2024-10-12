//
//  ActivityListView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//

import SwiftUI

struct ActivityListView: View {
    var activities: [Activity]
    @State private var isShowingCreateActivity = false

    var body: some View {
        VStack {
            Text("ActivityListView")
            List {
                ForEach(activities) { activity in
                    NavigationLink(destination: ActivityDetailView(activity: activity)) {
                        ActivityCellView(activity: activity)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Activities")
            .navigationBarItems(
                trailing: Button(action: {
                    isShowingCreateActivity.toggle()
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $isShowingCreateActivity) {
                CreateEditActivity()
            }
        }
    }
}
