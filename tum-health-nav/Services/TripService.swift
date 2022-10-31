//
//  TripService.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 30.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import Foundation
import MapboxGeocoder

// MARK: - ServiceProtocol

protocol TripService {
    
    func initOTPPlan(otpPlan: LoadableSubject<OTPPlan>)
    
    func updateTripStartDate(date: Date)
    
    func updateTripEndDate(date: Date)
    
    func setStartingPointPlacemarks(for address: String)
    
    func setDestinationPlacemarks(for address: String)
    
    func setStartingPointLocation(to placemark: GeocodedPlacemark?)
    
    func setDestinationLocation(to placemark: GeocodedPlacemark?)
    
    func setStartingPointLocationToCurrent()
    
    func setDestinationLocationToCurrent()
    
    func setLeaveBy(to date: Date)
}

// MARK: - RealService

struct RealTripService: TripService {
    
    let appState: Store<AppState>
    let otpRepository: OTPRepository
    private let geocoder = Geocoder.shared
    
    //    func initOTPPlan(otpPlan: LoadableSubject<OTPPlan>, completion: @escaping () -> Void) {
    func initOTPPlan(otpPlan: LoadableSubject<OTPPlan>) {
        let cancelBag = CancelBag()
        //        self.errorOccured = false
        otpPlan.wrappedValue = .isLoading(last: nil, cancelBag: cancelBag)
        guard let otpRequest = getOTPRequest() else {
            return
        }
        otpRepository.getOTPResponse(otpRequest: otpRequest)
            .sinkToLoadable {
                otpPlan.wrappedValue = $0
            }
            .store(in: cancelBag)
    }
    
    private func getOTPRequest() -> OTPRequest? {
        guard let startingPoint = appState.value.trip.startingPoint.location,
              let destination = appState.value.trip.destination.location else {
            return nil
        }
        let leaveBy = appState.value.trip.leaveBy
        let activeModes = appState.value.navigationConstraints.activeModes
        let constrainsPreferences = appState.value.navigationConstraints.constraintPreferences
        let constraints = getOTPRequestConstraints(constraintPreferences: constrainsPreferences)
        
        return OTPRequest(
            date: leaveBy,
            fromPlace: startingPoint,
            toPlace: destination,
            modes: activeModes,
            bikeLocation: nil,
            constraints: constraints
        )
    }
    
    private func getOTPRequestConstraints(constraintPreferences: [RangeDistanceConstraintPreference]) -> OTPRequestConstraintWrapper {
        OTPRequestConstraintWrapper(constraints: [
            NestedOTPRequestConstraint(
                constraints: constraintPreferences
                    .flatMap { $0.getOTPRequestConstraints() }
                    .filter { appState.value.navigationConstraints.activeModes.contains($0.context.transportationMode) },
                isOperatorAnd: true
            )
        ])
    }
    
    func updateTripStartDate(date: Date) {
        DispatchQueue.main.async {
            self.appState[\.trip.startDate] = date
        }
    }
    
    func updateTripEndDate(date: Date) {
        DispatchQueue.main.async {
            self.appState[\.trip.endDate] = date
        }
    }
    
    func setStartingPointPlacemarks(for address: String) {
        let options = ForwardGeocodeOptions(query: address)
        options.autocompletesQuery = true
        options.allowedISOCountryCodes = ["DE"]
        
        if let coordinate = UserLocation().coordinate {
            options.focalLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        
        options.allowedScopes = [.address, .pointOfInterest]
        
        _ = geocoder.geocode(options) { placemarks, _, _ in
            guard let placemarks = placemarks else {
                return
            }
            self.appState[\.trip.startingPoint.placemarks] = placemarks
        }
    }
    
    func setDestinationPlacemarks(for address: String) {
        let options = ForwardGeocodeOptions(query: address)
        options.autocompletesQuery = true
        options.allowedISOCountryCodes = ["DE"]
        
        if let coordinate = UserLocation().coordinate {
            options.focalLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        
        options.allowedScopes = [.address, .pointOfInterest]
        
        _ = geocoder.geocode(options) { placemarks, _, _ in
            guard let placemarks = placemarks else {
                return
            }
            self.appState[\.trip.destination.placemarks] = placemarks
        }
    }
    
    func setStartingPointLocation(to placemark: GeocodedPlacemark?) {
        
        guard let placemark = placemark else {
            self.appState[\.trip.startingPoint.address] = ""
            self.appState[\.trip.startingPoint.location] = nil
            return
        }
        if let name = placemark.qualifiedName {
            self.appState[\.trip.startingPoint.address] = name
        }
        if let coordinate = placemark.location?.coordinate {
            self.appState[\.trip.startingPoint.location] = coordinate
        }
    }
    
    func setDestinationLocation(to placemark: GeocodedPlacemark?) {
        guard let placemark = placemark else {
            self.appState[\.trip.destination.address] = ""
            self.appState[\.trip.destination.location] = nil
            return
        }
        if let name = placemark.qualifiedName {
            self.appState[\.trip.destination.address] = name
        }
        if let coordinate = placemark.location?.coordinate {
            self.appState[\.trip.destination.location] = coordinate
        }
    }
    
    func setStartingPointLocationToCurrent() {
        guard let coordinate = UserLocation().locationManager.location?.coordinate else {
            return
        }
        self.appState[\.trip.startingPoint.address] = "Current Location"
        self.appState[\.trip.startingPoint.location] = coordinate
    }
    
    func setDestinationLocationToCurrent() {
        guard let coordinate = UserLocation().locationManager.location?.coordinate else {
            return
        }
        self.appState[\.trip.destination.address] = "Current Location"
        self.appState[\.trip.destination.location] = coordinate
    }
    
    func setLeaveBy(to date: Date) {
        DispatchQueue.main.async {
            self.appState[\.trip.leaveBy] = date
        }
    }
}

// MARK: - StubService

struct StubTripService: TripService {
    
    func initOTPPlan(otpPlan: LoadableSubject<OTPPlan>) {}
    
    func updateTripStartDate(date: Date) {}
    
    func updateTripEndDate(date: Date) {}
    
    func setStartingPointPlacemarks(for address: String) {}
    
    func setDestinationPlacemarks(for address: String) {}
    
    func setStartingPointLocation(to placemark: GeocodedPlacemark?) {}
    
    func setDestinationLocation(to placemark: GeocodedPlacemark?) {}
    
    func setStartingPointLocationToCurrent() {}
    
    func setDestinationLocationToCurrent() {}
    
    func setLeaveBy(to date: Date) {}
}
