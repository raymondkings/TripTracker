//
//  TripDetailView.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//

import SwiftUI

struct TripDetailView: View {
    var trip: Trip
    @Bindable var tripViewModel: TripViewModel
    @State private var isShowingEditTrip = false
    @State private var showSuccessToast = false
    var imageViewModel: ImageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(trip.id.uuidString)
                .font(.body)

            Text(trip.name)
                .font(.body)

            Text("Country: \(trip.country)")
                .font(.body)

            Text("Start Date: \(trip.startDate, formatter: dateFormatter)")
                .font(.body)

            Text("End Date: \(trip.endDate, formatter: dateFormatter)")
                .font(.body)

            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(trip.name)
                    .font(.body)
                    .lineLimit(1)
            }
        }
        .navigationBarItems(
            trailing: Button(action: {
                isShowingEditTrip.toggle()
            }) {
                Image(systemName: "pencil")
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        )
        .sheet(isPresented: $isShowingEditTrip) {
            CreateEditTrip(
                viewModel: tripViewModel,
                imageViewModel: imageViewModel,
                showSuccessToast: $showSuccessToast,
                tripToEdit: trip
            )
        }
    }
}
