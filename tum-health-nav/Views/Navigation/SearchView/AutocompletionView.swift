//
//  AutocompletionView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 28.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI
import MapboxGeocoder

// MARK: - View

struct AutocompletionView: View {
    
    @ObservedObject var viewModel: ViewModel
    @Binding var showCompletion: Bool
    
    var destination: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            ScrollView {
                VStack(alignment: .leading) {
                    getCurrentLocationCell()
                    Divider().padding(.leading)
                    
                    ForEach((self.destination ? viewModel.destinationPlacemarks : viewModel.startingPointPlacemarks).prefix(5)) { placemark in
                        getLocationCell(placemark: placemark)
                        Divider().padding(.leading)
                    }
                }
            }.gesture(DragGesture())
        }
    }
    
    func getCurrentLocationCell() -> AnyView {
        AnyView(
            HStack(spacing: 20.0) {
                Image(systemName: "location.fill")
                    .resizable()
                    .padding(5)
                    .frame(width: 32.0, height: 32.0)
                Text("Current Location").onTapGesture {
                    self.destination ? viewModel.setDestinationLocationToCurrent() : viewModel.setStartingPointLocationToCurrent()
                    self.showCompletion = false
                    UIApplication.shared.endEditing()
                }
            }.padding()
        )
    }
    
    func getLocationCell(placemark: GeocodedPlacemark) -> AnyView {
        AnyView(
            HStack(spacing: 20.0) {
                Image(systemName: "mappin.circle.fill")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
                Text(placemark.qualifiedName ?? "")
                    .onTapGesture {
                        self.destination ? viewModel.setDestinationLocation(placemark: placemark) :
                            viewModel.setStartingPointLocation(placemark: placemark)
                        self.showCompletion = false
                        UIApplication.shared.endEditing()
                    }
            }.padding()
        )
    }
}

// MARK: - ViewModel

extension AutocompletionView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var startingPointPlacemarks: [GeocodedPlacemark]
        @Published var destinationPlacemarks: [GeocodedPlacemark]
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            _startingPointPlacemarks = .init(wrappedValue: appState.value.trip.startingPoint.placemarks)
            _destinationPlacemarks = .init(wrappedValue: appState.value.trip.destination.placemarks)
            
            cancelBag.collect {
                $startingPointPlacemarks.sink { appState[\.trip.startingPoint.placemarks] = $0 }
                appState.map(\.trip.startingPoint.placemarks)
                    .removeDuplicates()
                    .assign(to: \.startingPointPlacemarks, on: self)
                
                $destinationPlacemarks.sink { appState[\.trip.destination.placemarks] = $0 }
                appState.map(\.trip.destination.placemarks)
                    .removeDuplicates()
                    .assign(to: \.destinationPlacemarks, on: self)
            }
        }
        
        func setStartingPointLocation(placemark: GeocodedPlacemark) {
            container.services.tripService.setStartingPointLocation(to: placemark)
        }
        
        func setDestinationLocation(placemark: GeocodedPlacemark) {
            container.services.tripService.setDestinationLocation(to: placemark)
        }
        
        func setStartingPointLocationToCurrent() {
            container.services.tripService.setStartingPointLocationToCurrent()
        }
        
        func setDestinationLocationToCurrent() {
            container.services.tripService.setDestinationLocationToCurrent()
        }
    }
}
        
// MARK: - Preview

#if DEBUG
struct AutocompletionView_Previews: PreviewProvider {
    static var previews: some View {
        AutocompletionView(viewModel: .init(container: .preview), showCompletion: .constant(true), destination: true)
    }
}
#endif
