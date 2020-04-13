//
//  AppDelegate.swift
//  Rid Covid 19
//
//  Created by Jacco Taal on 13/04/2020.
//  Copyright © 2020 Bitnomica. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let viewModel = MainViewModel()
        let viewController = MainViewController(viewModel: viewModel)
//        application.window.viewController = viewController
//        UIScreen.main.window.viewController = viewController
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        // Override point for customization after application launch.
        return true
    }

}

