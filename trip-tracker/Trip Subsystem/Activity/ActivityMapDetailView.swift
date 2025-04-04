//
//  ActivityMapDetailView.swift
//  trip-tracker
//
//  Created by Raymond King on 29.03.25.
//

import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
}

struct ActivityMapDetailView: View {
    var activity: Activity

    @StateObject private var locationManager = LocationManager()

    @State private var region = MKCoordinateRegion()
    @State private var activityCoordinate: CLLocationCoordinate2D?
    @State private var travelTimes: [TransportOption: TimeInterval] = [:]
    @State private var route: MKRoute?

    let transportOptions: [TransportOption] = [
        TransportOption(label: "Driving", systemImage: "car.fill", rawType: MKDirectionsTransportType.automobile.rawValue),
        TransportOption(label: "Walking", systemImage: "figure.walk", rawType: MKDirectionsTransportType.walking.rawValue),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            if let activityCoordinate {
                MapViewWrapper(region: $region, route: route, activityCoordinate: activityCoordinate, userCoordinate: locationManager.location)
                    .ignoresSafeArea()
            } else {
                ProgressView("Loading map...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            }

            if let _ = activityCoordinate {
                VStack(spacing: 8) {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(activity.name)
                            .font(.headline)

                        Text(activity.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("\u{1F4CD} \(activity.location)")
                            .font(.caption)

                        Text("\u{1F4C6} \(activity.date, formatter: dateFormatter)")
                            .font(.caption)

                        ForEach(transportOptions) { option in
                            HStack {
                                Image(systemName: option.systemImage)
                                Text(option.label)
                                if let time = travelTimes[option] {
                                    Text("~\(Int(time / 60)) min")
                                        .foregroundColor(.secondary)
                                } else {
                                    ProgressView()
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
                .padding()
            }
        }
        .navigationTitle("Activity Map")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: geocodeAndSetup)
    }

    private func geocodeAndSetup() {
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
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                setUpMapAndRoutes(with: coordinate)
            } else {
                print("Failed to find map item: \(error?.localizedDescription ?? "Unknown error")")
                self.activityCoordinate = nil
            }
        }
    }

    private func setUpMapAndRoutes(with coordinate: CLLocationCoordinate2D) {
        self.activityCoordinate = coordinate

        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        guard let userCoord = locationManager.location else {
            print("User location not available yet")
            return
        }

        calculateRoutes(to: coordinate, from: userCoord)
    }

    private func calculateRoutes(to destination: CLLocationCoordinate2D, from source: CLLocationCoordinate2D) {
        for option in transportOptions {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            request.transportType = option.type

            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                if let resultRoute = response?.routes.first {
                    DispatchQueue.main.async {
                        self.travelTimes[option] = resultRoute.expectedTravelTime

                        if option.type == .walking {
                            self.route = resultRoute
                        }
                    }
                }
            }
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

struct MapViewWrapper: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var route: MKRoute?
    var activityCoordinate: CLLocationCoordinate2D
    var userCoordinate: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true

        let activityAnnotation = MKPointAnnotation()
        activityAnnotation.coordinate = activityCoordinate
        activityAnnotation.title = "Activity Location"
        mapView.addAnnotation(activityAnnotation)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)

        uiView.removeOverlays(uiView.overlays)

        if let polyline = route?.polyline {
            uiView.addOverlay(polyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
