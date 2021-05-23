//
//  TasksTabViewController.swift
//  BringgDriverSDKExample
//
//  Created by Ido Mizrachi on 26/08/2020.
//

import BringgDriverSDK
import UIKit
import SnapKit

class TasksTabViewController: UIViewController {
    
    enum DisplayMode: Equatable {
        case notLoggedIn
        case tasks
        case clusters
    }
    
    private var notLoggedInView = NotLoggedInView()
    
    var displayMode: DisplayMode = .notLoggedIn
    
    var clustersViewController: ClustersViewController?
    var taskListViewController: TaskListViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshDisplayMode()
        refreshView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "merge"), style: .plain, target: self, action: #selector(groupTasks))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .white
        let oldDisplayMode = displayMode
        refreshDisplayMode()
        if oldDisplayMode != displayMode {
            refreshView()
        }
    }
    
    private func refreshDisplayMode() {
        if !Bringg.shared.loginManager.isLoggedIn {
            displayMode = .notLoggedIn
        } else if Bringg.shared.tasksManager.shouldUseClusters {
            displayMode = .clusters
        } else {
            displayMode = .tasks
        }
    }
    
    private func refreshView() {
        let childrenViewControllers = children
        childrenViewControllers.forEach {
            $0.willMove(toParent: nil)
            $0.removeFromParent()
            $0.view.removeFromSuperview()
        }
        clustersViewController = nil
        taskListViewController = nil
        let viewController: UIViewController
        switch displayMode {
        case .notLoggedIn:
            viewController = NotLoggedInViewController()
        case .tasks:
            let taskListViewController = TaskListViewController()
            self.taskListViewController = taskListViewController
            viewController = taskListViewController
            self.title = "Tasks"
        case .clusters:
            let clustersViewController = ClustersViewController()
            self.clustersViewController = clustersViewController
            viewController = clustersViewController
            self.title = "Tasks"
        }
        view.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    @objc private func groupTasks() {
        let groupTasksViewController = GroupTasksViewController()
        groupTasksViewController.delegate = self
        navigationController?.pushViewController(groupTasksViewController, animated: true)
    }
}

extension TasksTabViewController: GroupTasksViewControllerDelegate {
    func groupTasksViewControllerDidCreateGroup() {
        taskListViewController?.getTasksAndUpdateUI()
        clustersViewController?.getTasksAndUpdateUI()
    }
}
