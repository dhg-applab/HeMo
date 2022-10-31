//
//  SearchTextField.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 28.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - View

struct SearchTextField: View {
    
    @Binding var text: String
    var title: String
    
    var body: some View {
        TextField(title, text: $text)
            .multilineTextAlignment(.center)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .background(Color.white)
            .cornerRadius(80)
    }
}

// MARK: - Preview

#if DEBUG
struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(text: .constant("Current Location"), title: "Starting Point")
    }
}
#endif
