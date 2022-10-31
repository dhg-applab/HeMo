//
//  CompatibleIgnoresSafeAreaModifier.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 02.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - ViewModifier

struct CompatibleIgnoresSafeAreaModifier: ViewModifier {

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            GeometryReader { _ in
            content
            }.ignoresSafeArea(.keyboard, edges: .bottom)
        } else {
            content
        }
    }
}
