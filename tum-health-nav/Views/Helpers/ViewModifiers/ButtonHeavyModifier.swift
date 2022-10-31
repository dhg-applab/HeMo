//
//  ButtonHeavyModifier.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 15.05.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - ViewModifier

struct ButtonHeavyModifier: ViewModifier {
    var isDisabled: Bool
    var backgroundColor: Color
    var foregroundColor: Color
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding(15)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(isDisabled ? Color(UIColor.systemGray5) : backgroundColor)
            .foregroundColor(isDisabled ? Color(UIColor.systemGray6) : foregroundColor)
            .cornerRadius(15)
            .padding(.horizontal, 20)
    }
}
