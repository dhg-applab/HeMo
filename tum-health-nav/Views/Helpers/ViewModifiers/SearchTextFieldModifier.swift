//
//  SearchTextFieldModifier.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 02.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI

// MARK: - ViewModifier

struct SearchTextFieldModifier: ViewModifier {
    @Binding var text: String
    
    public func body(content: Content) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.gray)
            content
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.gray)
                }
                .padding(.trailing, 8)
            }
        }
    }
}
