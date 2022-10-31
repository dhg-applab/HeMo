//
//  ModalManager.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 04.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI


class ModalManager: ObservableObject {
    
    @Published var modal = Modal(position: .closed, content: nil)
    
    func newModal<Content: View>(position: ModalState, @ViewBuilder content: () -> Content ) {
        modal = Modal(position: position, content: AnyView(content()))
    }
    
    func openModal() {
        modal.position = .open
    }
    
    func closeModal() {
        modal.position = .closed
    }
    
    func getPosition() -> ModalState {
        modal.position
    }
}
