//
//  SheetModifier.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 03.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - ViewModifier

struct SheetModifier: ViewModifier {

    public func body(content: Content) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary)
                .frame(width: 60, height: 4)
                .padding(.top, 10)
            content
            Spacer()
        }
    }
}
