//
//  TripListView.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//
import SwiftUI

struct TripListView: View {
    @State var viewModel = TripViewModel()
    @State private var isShowingCreateTrip = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.trips) { trip in
                        NavigationLink(destination: ActivityListView(viewModel: viewModel, trip: trip)) {
                            TripCardView(trip: trip) {
                                viewModel.deleteTrip(trip)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Trips")
            .navigationBarItems(
                trailing: Button(action: {
                    isShowingCreateTrip.toggle()
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $isShowingCreateTrip) {
                CreateEditTrip(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    TripListView()
}
