//
//  ActivityIndicator.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 15.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

// MARK: - ViewRepresentable

struct ActivityIndicator: UIViewRepresentable {

    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}
