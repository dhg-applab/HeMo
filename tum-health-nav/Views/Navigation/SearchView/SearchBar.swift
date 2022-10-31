//
//  SearchBar.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 27.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI
import MapboxGeocoder

// MARK: - View

struct SearchBar: View {
    
    @EnvironmentObject var modalManager: ModalManager
    @ObservedObject var viewModel: ViewModel
    
    @Binding var showDestinationAutocompletion: Bool
    @Binding var showStartingPointAutocompletion: Bool
    @Binding var showTimePicker: Bool
    @Binding var showPreferences: Bool
    @State var disableGoButton = true
    @State var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            getSearchView()
            if showStartingPointAutocompletion {
                AutocompletionView(viewModel: .init(container: viewModel.container),
                                   showCompletion: $showStartingPointAutocompletion,
                                   destination: false)
            }
            if showDestinationAutocompletion {
                AutocompletionView(viewModel: .init(container: viewModel.container),
                                   showCompletion: $showDestinationAutocompletion,
                                   destination: true)
            }
            Spacer().frame(height: keyboardHeight)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            self.showDestinationAutocompletion = false
            self.showStartingPointAutocompletion = false
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
                .receive(on: RunLoop.main),
            perform: updateKeyboardHeight
        )
    }
    
    func getSearchView() -> AnyView {
        AnyView(
            VStack {
                if modalManager.getPosition() == ModalState.open {
                    getTextField(title: "Starting Point", text: $viewModel.startingPoint, onEditingChanged: { editing in
                        if viewModel.startingPoint.isEmpty {
                            viewModel.setStartingPointLocation(to: nil)
                        }
                        disableGoButton = viewModel.startingPoint.isEmpty || viewModel.destination.isEmpty
                        if editing {
                            self.showStartingPointAutocompletion = true
                        } else {
                            self.showStartingPointAutocompletion = false
                        }
                    })
                }
                getTextField(title: "Destination", text: $viewModel.destination, onEditingChanged: { editing in
                    if viewModel.destination.isEmpty {
                        viewModel.setDestinationLocation(to: nil)
                    }
                    disableGoButton = viewModel.startingPoint.isEmpty || viewModel.destination.isEmpty
                    if editing {
                        self.showDestinationAutocompletion = true
                    } else {
                        self.showDestinationAutocompletion = false
                    }
                })
                .onTapGesture {
                    self.modalManager.openModal()
                }
                if modalManager.getPosition() == ModalState.open {
                    getAdditionalInformationView()
                }
            }
            .padding([.horizontal, .bottom])
        )
    }
    
    func getAdditionalInformationView() -> AnyView {
        AnyView(
            HStack {
                HStack {
                    Text("Leave by").padding(.leading)
                    Spacer()
                    DatePicker("Leave by", selection: $viewModel.leaveBy, displayedComponents: .hourAndMinute)
                        .background(Color.clear)
                        .labelsHidden()
                }
                .frame(minWidth: 200)
                .background(Color(UIColor.systemGray4))
                .cornerRadius(10)
                
                Button(action: { self.showPreferences = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color.white)
                        .frame(width: 50, height: 35)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                getGoButton()
            }
        )
    }
    
    func getGoButton() -> AnyView {
        AnyView(
            NavigationLink(destination: SelectRouteView(viewModel: .init(container: viewModel.container)),
                           isActive: $viewModel.popToRoot) {
                Text("Go")
                    .padding(7)
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity)
            }
            .isDetailLink(false)
            .font(.headline)
            .background(Color.green)
            .opacity(disableGoButton ? 0.5 : 1)
            .cornerRadius(10)
            .multilineTextAlignment(.center)
            .disabled(disableGoButton)
            .simultaneousGesture(TapGesture().onEnded {
                UIApplication.shared.endEditing()
            })
        )
    }
    
    func getTextField(title: String, text: Binding<String>, onEditingChanged: @escaping ((Bool) -> Void)) -> AnyView {
        AnyView(
            TextField(title, text: text, onEditingChanged: onEditingChanged)
                .modifier(SearchTextFieldModifier(text: text))
                .padding(5)
                .background(Color(UIColor.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        )
    }
    
    func getTextField(title: String, text: Binding<String>) -> AnyView {
        AnyView(
            TextField(title, text: text)
                .padding(5)
                .background(Color(UIColor.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        )
    }
    
    func updateKeyboardHeight(_ notification: Notification) {
        guard let info = notification.userInfo else {
            return
        }
        guard let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        if keyboardFrame.origin.y == UIScreen.main.bounds.height {
            keyboardHeight = 0
        } else {
            guard (UIApplication.shared.keyWindow?.rootViewController) != nil else {
                return
            }
            keyboardHeight = keyboardFrame.height
        }
    }
}

// MARK: - ViewModel

extension SearchBar {
    class ViewModel: ObservableObject {
        
        // State
        @Published var startingPoint: String {
            didSet {
                container.services.tripService.setStartingPointPlacemarks(for: startingPoint)
            }
        }
        @Published var destination: String {
            didSet {
                container.services.tripService.setDestinationPlacemarks(for: destination)
            }
        }
        @Published var leaveBy: Date {
            didSet {
                container.services.tripService.setLeaveBy(to: leaveBy)
            }
        }
        
        @Published var popToRoot: Bool
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer) {
            self.container = container
            let appState = container.appState
            _startingPoint = .init(initialValue: "")
            _destination = .init(initialValue: "")
            _leaveBy = .init(initialValue: Date())
            _popToRoot = .init(wrappedValue: appState.value.general.popToRoot)
            
            cancelBag.collect {
                appState.map(\.trip.startingPoint.address)
                    .removeDuplicates()
                    .assign(to: \.startingPoint, on: self)

                appState.map(\.trip.destination.address)
                    .removeDuplicates()
                    .assign(to: \.destination, on: self)
                
                $leaveBy
                    .sink { appState[\.trip.leaveBy] = $0 }
                appState.map(\.trip.leaveBy)
                    .removeDuplicates()
                    .assign(to: \.leaveBy, on: self)
                
                $popToRoot
                    .sink { appState[\.general.popToRoot] = $0 }
                appState.map(\.general.popToRoot)
                    .removeDuplicates()
                    .assign(to: \.popToRoot, on: self)
            }
        }
        
        func setStartingPointLocation(to placemark: GeocodedPlacemark?) {
            container.services.tripService.setStartingPointLocation(to: placemark)
        }
        
        func setDestinationLocation(to placemark: GeocodedPlacemark?) {
            container.services.tripService.setDestinationLocation(to: placemark)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(viewModel: .init(container: .preview),
                  showDestinationAutocompletion: .constant(false),
                  showStartingPointAutocompletion: .constant(false),
                  showTimePicker: .constant(false),
                  showPreferences: .constant(false),
                  disableGoButton: false)
            .background(Color.white)
    }
}
#endif
