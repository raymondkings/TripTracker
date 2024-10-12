//
//  ActivityDetailView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//

import SwiftUI

struct ActivityDetailView: View {
    var activity: Activity

    var body: some View {
        VStack {
            Text("ActivityDetailView")
            Text(activity.name)
            Text(activity.description)
        }
        .navigationTitle(activity.name)
    }
}
