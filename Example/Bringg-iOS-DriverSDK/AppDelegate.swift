//
//  Copyright © 2018 Bringg. All rights reserved.
//

import UIKit
import BringgDriverSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var mainTabController = MainTabViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
