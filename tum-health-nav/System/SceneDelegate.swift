//
//  SceneDelegate.swift
//  tum-health-nav
//
//  Created by Sven Andabaka on 05.06.20.
//  Copyright © 2020 TUM. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let environment = AppEnvironment.bootstrap()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Create the SwiftUI view that provides the window contents.
        
        let contentView = MainView(viewModel: MainView.ViewModel(container: environment.container))

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        environment.save()
    }
}
