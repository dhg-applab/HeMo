//
//  MapView.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 07.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct MapView: View {
    
    @EnvironmentObject var modalManager: ModalManager
    @ObservedObject var viewModel: ViewModel
    
    @State var showTimePicker = false
    @State var showPreferences = false
    @State var showDestinationAutocompletion = false
    @State var showStartingPointAutocompletion = false
    @State var trackUser = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MapViewWrapper(trackUser: self.$trackUser, viewModel: .init(container: viewModel.container, otpPlan: nil))
                    .followUser()
                    .zoomLevel(16)
                    .edgesIgnoringSafeArea(.all)
                getFollowUserButton()
                ModalAnchorView().environmentObject(modalManager)
            }
            .sheet(isPresented: $showPreferences) {
                PreferencesView(viewModel: .init(container: viewModel.container))
                    .modifier(SheetModifier())
            }
            .onAppear {
                if modalManager.modal.content == nil {
                    self.viewModel.setStartingPointLocationToCurrent()
                    modalManager.newModal(position: .closed) {
                        VStack {
                            getSearchBar()
                            Spacer()
                        }.modifier(SheetModifier())
                    }
                }
                self.viewModel.setNavigationBarHidden(to: true)
                print("MapView")
            }
            .navigationBarTitle("")
            .navigationBarHidden(self.viewModel.navigationBarHidden)
        }
    }
    
    func getSearchBar() -> AnyView {
        AnyView(
            SearchBar(viewModel: .init(container: viewModel.container),
                      showDestinationAutocompletion: $showDestinationAutocompletion,
                      showStartingPointAutocompletion: $showStartingPointAutocompletion,
                      showTimePicker: $showTimePicker,
                      showPreferences: $showPreferences)
        )
    }
    
    func getFollowUserButton() -> AnyView {
        AnyView(
            HStack {
                Spacer()
                Button(action: {
                    self.trackUser = true
                }) {
                    Image(systemName: "location.fill")
                        .foregroundColor(Color.white)
                        .frame(width: 50, height: 35)
                        .background(Color(UIColor.systemGray4))
                        .cornerRadius(10)
                }
                .opacity(!(self.modalManager.getPosition() == ModalState.open) ? 1.0 : 0)
                .disabled(self.modalManager.getPosition() == ModalState.open)
                .animation(.easeIn(duration: 0.2))
                .padding()
            }
        )
    }
}

// MARK: - ViewModel

extension MapView {
    class ViewModel: ObservableObject {
        
        // State
        @Published var navigationBarHidden: Bool
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            _navigationBarHidden = .init(wrappedValue: appState.value.general.navigationBarHidden)
            
            cancelBag.collect {
                appState.map(\.general.navigationBarHidden)
                    .removeDuplicates()
                    .assign(to: \.navigationBarHidden, on: self)
            }
        }
        
        func setStartingPointLocationToCurrent() {
            container.services.tripService.setStartingPointLocationToCurrent()
        }
        
        func setNavigationBarHidden(to navigationBarHidden: Bool) {
            container.services.generalSerive.setNavigationBarHidden(to: navigationBarHidden)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TabView {
                MapView(viewModel: .init(container: .preview))
            }.previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")
            
            TabView {
                MapView(viewModel: .init(container: .preview))
            }.previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
            
            TabView {
                MapView(viewModel: .init(container: .preview))
            }.previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
            .previewDisplayName("iPhone 12 Pro Max")
        }
    }
}
#endif
