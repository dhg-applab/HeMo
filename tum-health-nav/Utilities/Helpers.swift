//
//  Helpers.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 19.02.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - View Inspection helper

internal final class Inspection<V> where V: View {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()
    
    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}
