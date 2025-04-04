//
//  ActivityMapOverviewView.swift
//  trip-tracker
//
//  Created by Raymond King on 04.04.25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ActivityMapOverviewView: View {
    var trip: Trip

    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion()
    @State private var annotations: [MKPointAnnotation] = []
    @State private var mapView: MKMapView? = nil

    var body: some View {
        ZStack {
            MapViewWrappers(annotations: annotations, region: $region, mapView: $mapView)
                .ignoresSafeArea()
        }
        .onAppear {
            geocodeActivities()
        }
        .navigationTitle("Activity Overview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func geocodeActivities() {
        let activities = trip.activities
        var newAnnotations: [MKPointAnnotation] = []
        let dispatchGroup = DispatchGroup()

        for activity in activities {
            dispatchGroup.enter()
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = activity.location

            if let userCoord = locationManager.location {
                request.region = MKCoordinateRegion(
                    center: userCoord,
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                )
            }

            let search = MKLocalSearch(request: request)
            search.start { response, error in
                defer { dispatchGroup.leave() }

                guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                    print("Failed to find location for \(activity.name)")
                    return
                }

                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = activity.name
                annotation.subtitle = activity.location
                newAnnotations.append(annotation)
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.annotations = newAnnotations
            if let first = newAnnotations.first {
                region = MKCoordinateRegion(center: first.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            }
        }
    }
}

struct MapViewWrappers: UIViewRepresentable {
    var annotations: [MKPointAnnotation]
    @Binding var region: MKCoordinateRegion
    @Binding var mapView: MKMapView?

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.setRegion(region, animated: false)
        map.showsUserLocation = true
        DispatchQueue.main.async {
            self.mapView = map
        }
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
        uiView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {}
}
