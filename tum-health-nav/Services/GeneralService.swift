//
//  GeneralService.swift
//  tum-health-nav
//
//  Created by Nikolai Madlener on 31.01.21.
//  Copyright © 2021 TUM. All rights reserved.
//

import Foundation

// MARK: - ServiceProtocol

protocol GeneralService {
    
    func setActiveCard(index: Int)
    
    func setNavigationBarHidden(to navigationBarHidden: Bool)
    
    func setPopToRoot(to popToRoot: Bool)
    
    func setOnboarded()
}

// MARK: - RealService

struct RealGeneralService: GeneralService {
    
    let appState: Store<AppState>
    
    func setActiveCard(index: Int) {
        DispatchQueue.main.async {
            self.appState[\.general.activeCard] = index
        }
    }
    
    func setNavigationBarHidden(to navigationBarHidden: Bool) {
        DispatchQueue.main.async {
            self.appState[\.general.navigationBarHidden] = navigationBarHidden
        }
    }
    
    func setPopToRoot(to popToRoot: Bool) {
        DispatchQueue.main.async {
            self.appState[\.general.popToRoot] = popToRoot
        }
    }
    
    func setOnboarded() {
        DispatchQueue.main.async {
            self.appState[\.general.onboarded] = true
        }
    }
}

// MARK: - StubService

struct StubGeneralService: GeneralService {
    
    func setActiveCard(index: Int) {}
    
    func setNavigationBarHidden(to navigationBarHidden: Bool) {}
    
    func setPopToRoot(to popToRoot: Bool) {}
    
    func setOnboarded() {}
}
