//
//  AppDelegate.swift
//  BringgDriverSDKExample
//
//  Copyright (c) 2020 Bringg. All rights reserved.
//

import BringgDriverSDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let bringgInitializationError = Bringg.initializeSDK(logger: Logger())

        if let initError = bringgInitializationError {
            fatalError("Bringg SDK failed to initialize. Nothing to do here anymore. error: \(initError.localizedDescription)")
        }

        let navigationController = MainTabViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
