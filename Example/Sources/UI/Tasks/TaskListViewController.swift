//
//  TaskListViewController.swift
//  BringgDriverSDKExample
//
//  Copyright © 2020 Bringg. All rights reserved.
//

import BringgDriverSDKObjc
import FSPagerView
import SnapKit
import UIKit

extension TaskStatus {
    func taskStatusString() -> String {
        switch self {
        case .invalid: return "invalid"
        case .free: return "free"
        case .assigned: return "assigned"
        case .onTheWay: return "onTheWay"
        case .checkedIn: return "checkedIn"
        case .checkedOut: return "checkedOut"
        case .accepted: return "accepted"
        case .cancelled: return "cancelled"
        }
    }
}

class TaskListViewController: UIViewController {
    private enum Sections: Int {
        case tasks
    }
    
    //Views
    
    private var notLoggedInView = NotLoggedInView()
    
    private lazy var tasksTableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    //State
    private var tasks: [Task]?
    private var lastTimeTasksWereRefreshed: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tasksTableView.register(TaskTableCellView.self, forCellReuseIdentifier: TaskTableCellView.cellIdentifier)
        
        view.addSubview(tasksTableView)
        view.addSubview(notLoggedInView)

        makeConstraints()
        
        Bringg.shared.tasksManager.addDelegate(self)
        Bringg.shared.loginManager.addDelegate(self)
        
        tasksTableView.isEditing = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getTasksAndUpdateUI()
    }
    
    func getTasksAndUpdateUI() {
        if !Bringg.shared.loginManager.isLoggedIn {
            notLoggedInView.isHidden = false
            return
        }
        notLoggedInView.isHidden = true
        Bringg.shared.tasksManager.getTasks { [weak self] tasks, lastTimeTasksWereRefreshed, error in
            guard let self = self else { return }
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            self.tasks = tasks?.sorted(by: { task1, task2 in
                if let priority1 = task1.priority, let priority2 = task2.priority {
                    return priority1 > priority2
                }
                return task1.id > task2.id
            })
            self.lastTimeTasksWereRefreshed = lastTimeTasksWereRefreshed
            self.tasksTableView.reloadData()
        }
    }
    
    private func makeConstraints() {
        tasksTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        notLoggedInView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func editButtonPressed() {
        tasksTableView.isEditing = !tasksTableView.isEditing
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let task = tasks?[indexPath.row] else { return }
        let taskViewController = TaskViewController(task: task)
        taskViewController.delegate = self
        navigationController?.pushViewController(taskViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableCellView.cellIdentifier, for: indexPath)
        cell.selectionStyle = .none
        if let taskCell = cell as? TaskTableCellView {
            let task = tasks?[indexPath.row]
            taskCell.task = task
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }
        switch section {
        case .tasks:
            return "Tasks"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let task = self.tasks!.remove(at: sourceIndexPath.row)
        self.tasks!.insert(task, at: destinationIndexPath.row)
        let taskIds = self.tasks!.map { $0.id }
        Bringg.shared.tasksManager.updateTasksPriorities(orderedTaskIds: taskIds, completion: nil)
    }
}

// MARK: TaskViewControllerDelegate

extension TaskListViewController: TaskViewControllerDelegate {
    func taskViewControllerDidCompleteTask() {
        self.navigationController?.popToViewController(self, animated: true)
        self.getTasksAndUpdateUI()
    }
    
    func taskViewControllerDidUngroupTask() {        
        self.navigationController?.popToViewController(self, animated: true)
        self.getTasksAndUpdateUI()
    }
}

// MARK: TasksManagerDelegate

extension TaskListViewController: TasksManagerDelegate {
    func tasksManagerDidRefreshTaskList(_ tasksManager: TasksManagerProtocol) {
        getTasksAndUpdateUI()
    }
    
    func tasksManager(_ tasksManager: TasksManagerProtocol, didAddNewTask taskId: Int) {
        getTasksAndUpdateUI()
    }
    
    func tasksManager(_ tasksManager: TasksManagerProtocol, didUpdateTask taskId: Int) {
        getTasksAndUpdateUI()
    }
    func tasksManager(_ tasksManager: TasksManagerProtocol, didAutoStartTask taskId: Int) { }
    
    func tasksManager(_ tasksManager: TasksManagerProtocol, didRemoveTask task: Task) {
        getTasksAndUpdateUI()
    }
    
    func tasksManager(_ tasksManager: TasksManagerProtocol, didMassRemoveTasks tasks: [Task]) {
        getTasksAndUpdateUI()
    }
}

// MARK: UserEventsDelegate

extension TaskListViewController: UserEventsDelegate {
    func userDidLogin() {
        getTasksAndUpdateUI()
    }
    
    func userDidLogout() {
        getTasksAndUpdateUI()
    }
}
