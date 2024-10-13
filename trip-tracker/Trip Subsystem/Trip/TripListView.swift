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
    @State private var imageViewModel = ImageViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.trips) { trip in
                        NavigationLink(destination:
                                        TripDetailView(trip: trip,
                                                                   tripViewModel:
                                                        viewModel, imageViewModel:
                                                        imageViewModel)) {
                            TripCardView(trip: trip, imageUrl: trip.imageUrl) {
                                viewModel.deleteTrip(trip)
                            }
                        }
                    }
                }.padding(16)
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
                CreateEditTrip(viewModel: viewModel, imageViewModel: imageViewModel)
            }
        }
    }
}

#Preview {
    TripListView()
}
