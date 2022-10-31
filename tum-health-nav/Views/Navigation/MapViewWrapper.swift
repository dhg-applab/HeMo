//
//  MapView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 07.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI
import Mapbox

// MARK: - ViewRepresentable

struct MapViewWrapper: UIViewRepresentable {
    
    @State private var mapView = MGLMapView(frame: .zero, styleURL: URL(string: "mapbox://styles/nikolaimadlener/ckjfpmngwnfuk19qova2c8i45"))
    @Binding var trackUser: Bool
    @ObservedObject var viewModel: ViewModel
    
    func makeUIView(context: UIViewRepresentableContext<MapViewWrapper>) -> MGLMapView {
        MGLLoggingConfiguration.shared.loggingLevel = .none
        mapView.compassView.compassVisibility = .hidden
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MGLMapView, context: UIViewRepresentableContext<MapViewWrapper>) {
        trackUser(uiView)
        showActiveCardRoute()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func trackUser(_ view: MGLMapView) {
        if trackUser {
            view.userTrackingMode = .follow
            trackUser = false
        }
    }
    
    func followUser() -> MapViewWrapper {
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        return self
    }
    
    func followUserWithCourse() -> MapViewWrapper {
        mapView.setUserTrackingMode(.followWithCourse, animated: false, completionHandler: nil)
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        return self
    }
    
    func zoomLevel(_ zoomLevel: Double) -> MapViewWrapper {
        mapView.zoomLevel = zoomLevel
        return self
    }
    
    func showActiveCardRoute() {
        if let otpPlan = viewModel.otpPlan {
            mapView.style?.layers.filter { $0.identifier.contains("polyline-") }.forEach { $0.isVisible = false }
            mapView.style?.layers.filter { $0.identifier.contains("marker-style-") }.forEach { $0.isVisible = false }
            mapView.style?.layers.filter { $0.identifier.contains("polyline-" + "\(viewModel.activeCard)-") }.forEach { $0.isVisible = true }
            mapView.style?.layers.filter { $0.identifier.contains("marker-style-" + "\(viewModel.activeCard)-") }.forEach { $0.isVisible = true }
            fitCamera(startPoint: otpPlan.fromPlace.coordinate, endPoint: otpPlan.toPlace.coordinate, animated: true)
        }
    }

    func addAnnotations() {
        guard let otpPlan = viewModel.otpPlan else {
            return
        }
        
        for index in 0..<otpPlan.itineraries.count {
            addAnnotations(for: otpPlan.itineraries[index], index: index)
        }
        fitCamera(startPoint: otpPlan.fromPlace.coordinate, endPoint: otpPlan.toPlace.coordinate, animated: false)
        addFinishPoint(for: otpPlan.toPlace.coordinate)
    }
    
    func addAnnotations(for itinerary: Itinerary, index: Int) {
        for leg in itinerary.legs {
            addAnnotations(forLeg: leg.getPolyline(), mode: leg.mode, legIdentifier: "\(index)-" + leg.id)
        }
    }
    
    func addAnnotations(for itinerary: Itinerary) -> MapViewWrapper {
        for leg in itinerary.legs {
            addAnnotations(forLeg: leg.getPolyline(), mode: leg.mode, legIdentifier: leg.id + "\(UUID())")
        }
        return self
    }
    
    func addAnnotations(forLeg coordinates: [CLLocationCoordinate2D], mode: RouteMode, legIdentifier: String) {
        if coordinates.isEmpty {
            print("empty coordinates")
            return
        }
        
        let legIdentifier = legIdentifier
        mapView.isZoomEnabled = true
        
        // Create sources
        let source = MGLShapeSource(identifier: "polyline-" + legIdentifier, shape: nil, options: nil)
        mapView.style?.addSource(source)
        
        // Add polyline
        let polyline = getPolyline(coordinates: coordinates, mode: mode, source: source, legIdentifier: legIdentifier)
        print(polyline)
        source.shape = polyline
        
        // Add startPoint
        if let firstCoordinate = coordinates.first {
            addPoint(coordinate: firstCoordinate, mode: mode, legIdentifier: legIdentifier)
        }
    }
    
    func fitCamera(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D, animated: Bool) {
        let camera = mapView.cameraThatFitsCoordinateBounds(MGLCoordinateBounds(sw: startPoint, ne: endPoint),
                                                            edgePadding: UIEdgeInsets(top: 40, left: 80, bottom: 400, right: 80))
        mapView.setCamera(camera, animated: animated)
    }
    
    func addFinishPoint(for coordinate: CLLocationCoordinate2D) {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    private func getPolyline(coordinates: [CLLocationCoordinate2D],
                             mode: RouteMode,
                             source: MGLShapeSource,
                             legIdentifier: String) -> MGLPolylineFeature {
        let layer = getLayer(mode: mode, source: source, legIdentifier: legIdentifier)
        mapView.style?.addLayer(layer)
        return MGLPolylineFeature(coordinates: coordinates, count: UInt(coordinates.count))
    }
    
    private func addPoint(coordinate: CLLocationCoordinate2D, mode: RouteMode, legIdentifier: String) {
        
        let point = MGLPointAnnotation()
        point.coordinate = coordinate
        
        // Create a data source to hold the point data
        let shapeSource = MGLShapeSource(identifier: "marker-source-" + legIdentifier, shape: point, options: nil)
        
        // Create a style layer for the symbol
        let shapeLayer = MGLSymbolStyleLayer(identifier: "marker-style-" + legIdentifier, source: shapeSource)
        
        // Add the image to the style's sprite
        
        if let image = getImage(for: mode)?.maskWithColor(color: getColorForIcon(for: mode)) {
            mapView.style?.setImage(image, forName: "mode-symbol-" + legIdentifier)
        }
        
        // Tell the layer to use the image in the sprite
        shapeLayer.iconImageName = NSExpression(forConstantValue: "mode-symbol-" + legIdentifier)
        shapeLayer.iconScale = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                            [10: 0.2, 18: 0.8])
        // Add the source and style layer to the map
        mapView.style?.addSource(shapeSource)
        mapView.style?.addLayer(shapeLayer)
    }
    
    private func getColorForIcon(for mode: RouteMode) -> UIColor {
        UIColor.white
    }
    
    private func getColor(for mode: RouteMode) -> UIColor {
        
        switch mode {
        case .walk:
            return Config.walkColor.uiColor()
        case .bicycle:
            return Config.bikeColor.uiColor()
        case .bus, .rail, .subway, .tram:
            return Config.transitColor.uiColor()
        case .car:
            return Config.carColor.uiColor()
        default:
            return UIColor.black
        }
    }
    
    private func getImage(for mode: RouteMode) -> UIImage? {
        let imageName: String
        switch mode {
        case .bicycle:
            imageName = "bicycle.circle"
        case .walk:
            imageName = "figure.walk.circle"
        case .bus:
            imageName = "bus"
        case .tram, .rail, .subway:
            imageName = "tram.circle"
        case .car:
            imageName = "car.circle"
        default:
            imageName = "questionmark.circle"
        }
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 64)
        return UIImage(systemName: imageName, withConfiguration: configuration)
    }
    
    private func getLayer(mode: RouteMode, source: MGLShapeSource, legIdentifier: String) -> MGLLineStyleLayer {
        let layer = MGLLineStyleLayer(identifier: "polyline-" + legIdentifier, source: source)
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineColor = NSExpression(forConstantValue: getColor(for: mode))
        layer.lineOpacity = NSExpression(forConstantValue: 0.6)
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 6, 18: 20])
        
        return layer
    }
    
    final class Coordinator: NSObject, MGLMapViewDelegate {
        var control: MapViewWrapper

        init(_ control: MapViewWrapper) {
            self.control = control
        }

        func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
            control.addAnnotations()
            control.showActiveCardRoute()
        }
    }
}

// MARK: - ViewModel

extension MapViewWrapper {
    class ViewModel: ObservableObject {
        
        // State
        @Published var otpPlan: OTPPlan?
        @Published var activeCard: Int

        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer, otpPlan: OTPPlan?) {
            self.container = container
            let appState = container.appState
            _otpPlan = .init(wrappedValue: otpPlan)
            _activeCard = .init(wrappedValue: appState.value.general.activeCard)
            
            cancelBag.collect {
                appState.map(\.general.activeCard)
                    .removeDuplicates()
                    .assign(to: \.activeCard, on: self)
            }
        }
    }
}
