//
//  ModalModifiers.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 04.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct ModalView: View {
    
    @Binding var modal: Modal
    @Binding var dragOffset: CGSize
    
    @GestureState var dragState: DragState = .inactive
    
    var animation: Animation {
        Animation
            .interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)
            .delay(0)
    }
    
    var body: some View {
        
        let drag = DragGesture(minimumDistance: 30)
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onChanged {
                self.dragOffset = $0.translation
            }
            .onEnded(onDragEnded)
        
        return GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.black
                    .opacity(self.modal.position != .closed ? 0.2 : 0)
                    .onTapGesture {
                        self.modal.position = .closed
                        UIApplication.shared.endEditing()
                    }
                    .animation(.easeIn(duration: 0.2))
                ZStack(alignment: .top) {
                    self.modal.content
                        .frame(height: UIScreen.main.bounds.height - (self.modal.position.offsetFromTop() +
                                                                        geometry.safeAreaInsets.top + self.dragState.translation.height))
                }
                .background(Blur(style: .systemMaterialDark))
                .cornerRadius(25.0)
                .offset(y: max(UIScreen.main.bounds.height * 0.1,
                               self.modal.position.offsetFromTop() + self.dragState.translation.height + geometry.safeAreaInsets.top))
                .gesture(drag)
                .animation(self.dragState.isDragging ? nil : self.animation)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        
        // Setting stops
        let higherStop: ModalState
        let lowerStop: ModalState
        
        // Nearest position for drawer to snap to.
        let nearestPosition: ModalState
        
        // Determining the direction of the drag gesture and its distance from the top
        let dragDirection = drag.predictedEndLocation.y - drag.location.y
        let offsetFromTopOfView = modal.position.offsetFromTop() + drag.translation.height
        
        higherStop = .open
        lowerStop = .closed
        
        // Determining whether drawer is closest to top or bottom
        if (offsetFromTopOfView - higherStop.offsetFromTop()) < (lowerStop.offsetFromTop() - offsetFromTopOfView) {
            nearestPosition = higherStop
        } else {
            nearestPosition = lowerStop
        }
        
        // Determining the drawer's position.
        if dragDirection > 0 {
            modal.position = lowerStop
        } else if dragDirection < 0 {
            modal.position = higherStop
        } else {
            modal.position = nearestPosition
        }
        
        if modal.position == .closed {
            UIApplication.shared.endEditing()
        }
    }
}

enum DragState {
    
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}
