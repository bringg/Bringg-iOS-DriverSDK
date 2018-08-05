//
//  Copyright © 2018 Bringg. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

    private var taskListViewController: TaskListViewController = {
        let viewController = TaskListViewController()
        viewController.title = "Tasks"
        return viewController
    }()

    private var shiftViewController: ShiftViewController = {
        let viewController = ShiftViewController()
        viewController.title = "Shift"
        return viewController
    }()

    private var profileViewController: ProfileViewController = {
        let viewController = ProfileViewController()
        viewController.title = "Profile"
        return viewController
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
