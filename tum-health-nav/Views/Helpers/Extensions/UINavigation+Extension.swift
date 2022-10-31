//
//  UINavigation+Extension.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 13.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

extension UIApplication {
    var isKeyboardPresented: Bool {
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
                self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
            return true
        } else {
            return false
        }
    }
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
