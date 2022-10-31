//
//  Blur.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 02.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import UIKit
import SwiftUI

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
