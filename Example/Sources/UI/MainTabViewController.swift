//
//  ViewController.swift
//  BringgDriverSDKExample
//
//  Copyright © 2020 Bringg. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {
    private var profileViewController: ProfileViewController = {
        let viewController = ProfileViewController()
        viewController.title = "Profile"
        viewController.tabBarItem.image = UIImage(named: "profile")
        return viewController
    }()

    private var shiftViewController: ShiftViewController = {
        let viewController = ShiftViewController()
        viewController.title = "Shift"
        viewController.tabBarItem.image = UIImage(named: "shift")
        return viewController
    }()

    private var taskListViewController: TaskListViewController = {
        let viewController = TaskListViewController()
        viewController.title = "Tasks"
        viewController.tabBarItem.image = UIImage(named: "tasks")
        return viewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewControllers = [
            UINavigationController(rootViewController: profileViewController),
            UINavigationController(rootViewController: shiftViewController),
            UINavigationController(rootViewController: taskListViewController),
        ]
    }
}
