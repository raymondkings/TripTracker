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
    @Environment(\.colorScheme) var colorScheme
    @State private var isDarkMode = false

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
                trailing: HStack {
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
                    }
                }
            )
            .sheet(isPresented: $isShowingCreateTrip) {
                CreateEditTrip(viewModel: viewModel)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
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
