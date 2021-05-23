//
//  TaskListViewController.swift
//  BringgDriverSDKExample
//
//  Copyright © 2020 Bringg. All rights reserved.
//

import BringgDriverSDK
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
    private enum Sections: Int, CaseIterable {
        case tasks
        case breaks
    }
    
    //Views
    
    private var notLoggedInView = NotLoggedInView()
    
    private lazy var tasksTableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskTableCellView.self, forCellReuseIdentifier: TaskTableCellView.cellIdentifier)
        tableView.register(BreakTableCellView.self, forCellReuseIdentifier: BreakTableCellView.cellIdentifier)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    //State
    private var tasks: [Task]?
    private var breaks: [ScheduledBreak]?
    private var lastTimeTasksWereRefreshed: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(tasksTableView)
        view.addSubview(notLoggedInView)

        makeConstraints()
        
        Bringg.shared.tasksManager.addDelegate(self)
        Bringg.shared.loginManager.addDelegate(self)
        Bringg.shared.breaksManager.addDelegate(self)
        
        tasksTableView.isEditing = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTasksAndUpdateUI()
        getBreaksAndUpdateUI()
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

    func getBreaksAndUpdateUI() {
        guard Bringg.shared.loginManager.isLoggedIn else {
            notLoggedInView.isHidden = false
            return
        }
        notLoggedInView.isHidden = true
        Bringg.shared.breaksManager.getScheduledBreaks(cachePolicy: .reloadIgnoringCacheData) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let breaks):
                self.breaks = breaks
            case .failure(let error):
                self.breaks = []
                self.showError(error.localizedDescription)
            }
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
        switch Sections(rawValue: indexPath.section) {
        case .tasks:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TaskTableCellView.cellIdentifier,
                for: indexPath
            ) as! TaskTableCellView
            cell.selectionStyle = .none
            let task = tasks?[indexPath.row]
            cell.task = task
            return cell
        case .breaks:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: BreakTableCellView.cellIdentifier,
                for: indexPath
            ) as! BreakTableCellView
            cell.selectionStyle = .none
            let breakModel = breaks?[indexPath.row]
            cell.breakModel = breakModel
            cell.onAction = { [weak self] in self?.breakActionPressed(breakModel) }
            return cell
        case .none:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }
        switch section {
        case .tasks:
            return "Tasks"
        case .breaks:
            return "Breaks"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .tasks:
            return tasks?.count ?? 0
        case .breaks:
            return breaks?.count ?? 0
        case .none:
            return 0
        }
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

extension TaskListViewController: BreaksManagerDelegate {
    func breaksDataChanged(_ sender: BreaksManagerProtocol) {
        getBreaksAndUpdateUI()
    }

    private func breakActionPressed(_ breakModel: ScheduledBreak?) {
        guard let breakModel = breakModel else { return }
        if breakModel.isStarted() {
            try? Bringg.shared.breaksManager.endBreak(breakId: breakModel.id)
        } else {
            try? Bringg.shared.breaksManager.startBreak(breakId: breakModel.id)
        }
        getBreaksAndUpdateUI()
    }
}
