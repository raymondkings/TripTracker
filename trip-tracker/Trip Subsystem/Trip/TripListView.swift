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
    @State private var isDarkMode = false
    
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
        .preferredColorScheme(isDarkMode ? .dark : .light)
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
                isDarkMode.toggle()
                toggleColorScheme()
            }) {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .foregroundColor(isDarkMode ? .yellow : .blue)
            }
            Button(action: {
                isShowingCreateTrip.toggle()
            }) {
                Image(systemName: "plus")
                    .frame(width: 44, height: 44)
            }
        }
    }

    private func toggleColorScheme() {
        if colorScheme == .dark {
            isDarkMode = false
        } else {
            isDarkMode = true
        }
    }
}
    
#Preview {
    TripListView()
}
