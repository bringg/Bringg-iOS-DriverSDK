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
        Bringg.initializeSDK(logger: Logger())
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = mainTabController
        window?.makeKeyAndVisible()
        return true
    }
}
