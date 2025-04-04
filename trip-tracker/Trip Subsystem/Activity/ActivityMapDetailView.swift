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

    let transportOptions: [TransportOption] = [
        TransportOption(label: "Driving", systemImage: "car.fill", rawType: MKDirectionsTransportType.automobile.rawValue),
        TransportOption(label: "Walking", systemImage: "figure.walk", rawType: MKDirectionsTransportType.walking.rawValue),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            if let activityCoordinate {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [activity]) { _ in
                    MapMarker(coordinate: activityCoordinate, tint: .blue)
                }
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

                        Text("📍 \(activity.location)")
                            .font(.caption)

                        Text("📆 \(activity.date, formatter: dateFormatter)")
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

        // Use user's location (if available) to bias the search region
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
                if let route = response?.routes.first {
                    DispatchQueue.main.async {
                        self.travelTimes[option] = route.expectedTravelTime
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
