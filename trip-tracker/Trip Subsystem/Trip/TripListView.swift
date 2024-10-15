//
//  TripListView.swift
//  trip-tracker
//
//  Created by Raymond King on 09.10.24.
//
import AlertToast
import SwiftUI

struct TripListView: View {
    @State var viewModel = TripViewModel()
    @State private var isShowingCreateTrip = false
    @State private var imageViewModel = ImageViewModel()
    @State private var showSuccessToast = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                tripListContent()
            }
            .navigationTitle("Trips")
            .navigationBarItems(trailing: addButton())
            .sheet(isPresented: $isShowingCreateTrip) {
                CreateEditTrip(
                    viewModel: viewModel,
                    imageViewModel: imageViewModel,
                    showSuccessToast: $showSuccessToast
                )
            }
            .toast(isPresenting: $showSuccessToast, duration: 2.0) {
                AlertToast(type: .complete(Color.green), title: "Trip Saved!")
            }
        }
    }
    
    // MARK: - Extracted Methods
    
    private func tripListContent() -> some View {
        VStack(spacing: 16) {
            ForEach(viewModel.trips) { trip in
                NavigationLink(
                    destination: ActivityListView(
                        viewModel: viewModel, trip: trip
                    )
                ) {
                    TripCardView(
                        trip: trip,
                        imageUrl: trip.imageUrl,
                        onDelete: {
                            viewModel.deleteTrip(trip)
                        }, viewModel: viewModel
                    )
                }
            }
        }
        .padding(16)
    }
    
    private func addButton() -> some View {
        HStack {
            Button(action: {
                isShowingCreateTrip.toggle()
            }) {
                Image(systemName: "plus")
                    .frame(width: 44, height: 44)
            }
        }
    }
}
    
#Preview {
    TripListView()
}
