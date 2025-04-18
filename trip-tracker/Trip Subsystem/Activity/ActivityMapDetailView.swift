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
    @State private var routes: [UInt: MKRoute] = [:]
    @State private var selectedTransportOption: TransportOption = TransportOption(label: "Walking", systemImage: "figure.walk", rawType: MKDirectionsTransportType.walking.rawValue)
    @State private var mapView: MKMapView? = nil
    @State private var isTrackingUser: Bool = false

    let transportOptions: [TransportOption] = [
        TransportOption(label: "Driving", systemImage: "car.fill", rawType: MKDirectionsTransportType.automobile.rawValue),
        TransportOption(label: "Walking", systemImage: "figure.walk", rawType: MKDirectionsTransportType.walking.rawValue),
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let activityCoordinate {
                MapViewWrapper(
                    activity: activity,
                    route: routes[selectedTransportOption.rawType],
                    activityCoordinate: activityCoordinate,
                    userCoordinate: locationManager.location,
                    mapView: $mapView,
                    isTrackingUser: $isTrackingUser
                )
                .ignoresSafeArea()
            } else {
                ProgressView("Loading map...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            }

            if let _ = activityCoordinate {
                VStack {
                    HStack(spacing: 12) {
                        CircleMapControlButton(systemImage: isTrackingUser ? "location.fill" : "location") {
                            if let mapView = mapView {
                                let newMode: MKUserTrackingMode = (mapView.userTrackingMode == .none) ? .followWithHeading : .none
                                mapView.setUserTrackingMode(newMode, animated: true)
                            }
                        }

                        if let mapView = mapView, let activityCoord = activityCoordinate {
                            CircleMapControlButton(systemImage: "mappin.and.ellipse") {
                                let region = MKCoordinateRegion(center: activityCoord, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                                mapView.setRegion(region, animated: true)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing)

                    TripDetailsCard(
                        activity: activity,
                        travelTimes: travelTimes,
                        transportOptions: transportOptions,
                        selectedTransportOption: $selectedTransportOption,
                        dateFormatter: dateFormatter
                    )
                    .padding(.horizontal)
                }
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
                        self.routes[option.rawType] = resultRoute
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

struct TripDetailsCard: View {
    var activity: Activity
    var travelTimes: [TransportOption: TimeInterval]
    var transportOptions: [TransportOption]
    @Binding var selectedTransportOption: TransportOption
    var dateFormatter: DateFormatter

    var body: some View {
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

            Picker("Transport Mode", selection: $selectedTransportOption) {
                ForEach(transportOptions) { option in
                    if let time = travelTimes[option] {
                        Text("\(option.label) ~\(Int(time / 60)) min")
                            .tag(option)
                    }
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Button(action: {
                let escapedQuery = activity.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "http://maps.apple.com/?q=\(escapedQuery)") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "map")
                    Text("Open in Apple Maps")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

struct CircleMapControlButton: View {
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .imageScale(.medium)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
    }
}

struct MapViewWrapper: UIViewRepresentable {
    var activity: Activity
    var route: MKRoute?
    var activityCoordinate: CLLocationCoordinate2D
    var userCoordinate: CLLocationCoordinate2D?
    @Binding var mapView: MKMapView?
    @Binding var isTrackingUser: Bool

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true

        let activityAnnotation = MKPointAnnotation()
        activityAnnotation.coordinate = activityCoordinate
        activityAnnotation.title = activity.location
        map.addAnnotation(activityAnnotation)

        DispatchQueue.main.async {
            self.mapView = map
        }

        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)

        if let polyline = route?.polyline {
            uiView.addOverlay(polyline)
        }

        uiView.setUserTrackingMode(isTrackingUser ? .followWithHeading : .none, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWrapper

        init(parent: MapViewWrapper) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            DispatchQueue.main.async {
                self.parent.isTrackingUser = (mode != .none)
            }
        }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            // Detect if the user is interacting with the map (via gesture)
            if let view = mapView.subviews.first {
                for recognizer in view.gestureRecognizers ?? [] {
                    if recognizer.state == .began || recognizer.state == .ended {
                        DispatchQueue.main.async {
                            self.parent.isTrackingUser = false
                        }
                        break
                    }
                }
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer()
        }
    }

}
