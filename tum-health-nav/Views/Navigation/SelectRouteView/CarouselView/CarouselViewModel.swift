//
//  UIStateModel.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 15.10.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import SwiftUI

public class CarouselViewModel: ObservableObject {
    @Published var activeCard: Int
    @Published var screenDrag: Float
    
    // Misc
    let container: DIContainer
    private var cancelBag = CancelBag()
    
    init(container: DIContainer) {
        self.container = container
        let appState = container.appState
        _activeCard = .init(initialValue: 0)
        _screenDrag = .init(initialValue: 0.0)
        
        cancelBag.collect {
            $activeCard
                .sink { appState[\.general.activeCard] = $0 }
            appState.map(\.general.activeCard)
                .removeDuplicates()
                .assign(to: \.activeCard, on: self)
        }
    }
}
