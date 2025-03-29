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
    @State private var isShowingGenerateTripWithAI = false
    @State private var imageViewModel = ImageViewModel()
    @State private var showSuccessToast = false
    
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
            .sheet(isPresented: $isShowingGenerateTripWithAI, content: {
                GenerateTripWithAI(
                    tripViewModel : viewModel
                )
            })
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
            Menu {
                Button("Create Trip") {
                    isShowingCreateTrip = true
                }
                
                Button("Generate Trip with AI ✨") {
                    isShowingGenerateTripWithAI = true
                }
            } label: {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            }
        }
    }
}
    
//#Preview {
//    TripListView()
//}
