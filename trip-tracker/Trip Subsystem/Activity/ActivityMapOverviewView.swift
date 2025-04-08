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
    @State private var annotations: [ColoredAnnotation] = []
    @State private var mapView: MKMapView?

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
        var newAnnotations: [ColoredAnnotation] = []
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
            search.start { response, _ in
                defer { dispatchGroup.leave() }

                guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                    print("Failed to find location for \(activity.name)")
                    return
                }

                let annotation = ColoredAnnotation()
                annotation.coordinate = coordinate
                annotation.title = activity.name
                annotation.subtitle = activity.location

                switch activity.type {
                case .activity:
                    annotation.markerTintColor = .systemBlue
                case .accommodation:
                    annotation.markerTintColor = .systemPurple
                case .restaurant:
                    annotation.markerTintColor = .systemOrange
                }

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

class ColoredAnnotation: MKPointAnnotation {
    var markerTintColor: UIColor?
}

struct MapViewWrappers: UIViewRepresentable {
    var annotations: [ColoredAnnotation]
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

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "ActivityMarker"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            if let coloredAnnotation = annotation as? ColoredAnnotation {
                annotationView?.markerTintColor = coloredAnnotation.markerTintColor
                annotationView?.displayPriority = .required
            }

            return annotationView
        }
    }
}
