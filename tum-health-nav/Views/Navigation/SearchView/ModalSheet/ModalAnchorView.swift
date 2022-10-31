//
//  ModalView.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 04.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct ModalAnchorView: View {
    @EnvironmentObject var modalManager: ModalManager
    @State var dragOffset: CGSize = .zero
    
    var body: some View {
        ModalView(modal: $modalManager.modal, dragOffset: $dragOffset)
    }
}
