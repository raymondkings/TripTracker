//
//  TripListView.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//
import SwiftUI

struct TripListView: View {
    @Bindable var viewModel = TripViewModel()
    @State private var isShowingCreateTrip = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.trips) { trip in
                        NavigationLink(destination: TripDetailView(trip: trip)) {
                            TripCardView(trip: trip)
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
                CreateTrip(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    TripListView()
}
