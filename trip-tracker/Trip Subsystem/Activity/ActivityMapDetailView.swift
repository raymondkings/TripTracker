//
//  ActivityMapDetailView.swift
//  trip-tracker
//
//  Created by Raymond King on 29.03.25.
//
import SwiftUI
import MapKit

struct ActivityMapDetailView: View {
    var activity: Activity

    @State private var region = MKCoordinateRegion()
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var activityCoordinate: CLLocationCoordinate2D?
    @State private var travelTimes: [TransportOption: TimeInterval] = [:]

    let transportOptions: [TransportOption] = [
        TransportOption(label: "Driving", systemImage: "car.fill", rawType: MKDirectionsTransportType.automobile.rawValue),
        TransportOption(label: "Walking", systemImage: "figure.walk", rawType: MKDirectionsTransportType.walking.rawValue),
        TransportOption(label: "Transit", systemImage: "tram.fill", rawType: MKDirectionsTransportType.transit.rawValue)
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
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(activity.location) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                setUpMapAndRoutes(with: coordinate)
            } else {
                print("Failed to geocode activity location: \(error?.localizedDescription ?? "Unknown error")")

                // Fallback coordinate (e.g., center of Rome)
                let fallbackCoordinate = CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964)
                setUpMapAndRoutes(with: fallbackCoordinate)
            }
        }
    }
    
    private func setUpMapAndRoutes(with coordinate: CLLocationCoordinate2D) {
        self.activityCoordinate = coordinate
        self.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        let simulatedUser = CLLocationCoordinate2D(
            latitude: coordinate.latitude + 0.02,
            longitude: coordinate.longitude + 0.02
        )
        self.userLocation = simulatedUser

        calculateRoutes(to: coordinate, from: simulatedUser)
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
