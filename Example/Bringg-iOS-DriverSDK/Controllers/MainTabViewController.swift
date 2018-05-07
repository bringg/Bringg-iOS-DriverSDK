//
//  Copyright © 2018 Bringg. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

    private var taskListViewController: TaskListViewController = {
        let vc = TaskListViewController()
        vc.title = "Tasks"
        return vc
    }()
    
    private var shiftViewController: ShiftViewController = {
        let vc = ShiftViewController()
        vc.title = "Shift"
        return vc
    }()
    
    private var profileViewController: ProfileViewController = {
        let vc = ProfileViewController()
        vc.title = "Profile"
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [
            UINavigationController(rootViewController: profileViewController),
            UINavigationController(rootViewController: shiftViewController),
            UINavigationController(rootViewController: taskListViewController)
        ]
    }
}

