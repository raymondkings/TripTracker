//
//  AcitivityCellView.swift
//  trip-tracker
//
//  Created by Raymond King on 12.10.24.
//

import SwiftUI

struct ActivityCellView: View {
    //@State var activityViewModel: ActivityViewModel
    var activity: Activity

    var body: some View {
        VStack {
            Text(activity.name)
            Text(activity.description)
            Text("Date: \(activity.date, formatter: dateFormatter)")
            Text(activity.latitude.formatted())
            Text(activity.longitude.formatted())
        }
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
