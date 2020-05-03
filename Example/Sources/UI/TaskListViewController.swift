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

class TaskTableCellView: UITableViewCell {
    fileprivate static let cellIdentifier = "TaskTableCellViewCellIdentifier"
    
    fileprivate var task: Task? {
        didSet {
            if let task = self.task {
                taskTitleLabel.text = task.title
                externalIdLabel.text = "external id: \(task.externalId ?? "none")"
                let isAsap = task.asap ?? false
                statusAndAsapLabel.text = "status: \(task.status.taskStatusString()), \(isAsap ? "is asap" : "not asap")"
            } else {
                taskTitleLabel.text = nil
                externalIdLabel.text = nil
                statusAndAsapLabel.text = nil
            }
        }
    }
    
    private lazy var taskTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .black
        return label
    }()
    
    private lazy var externalIdLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .black
        return label
    }()
    
    private lazy var statusAndAsapLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(taskTitleLabel)
        addSubview(externalIdLabel)
        addSubview(statusAndAsapLabel)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func makeConstraints() {
        taskTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(8)
        }
        
        externalIdLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalTo(taskTitleLabel.snp.bottom).offset(8)
        }
        
        statusAndAsapLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalTo(externalIdLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-8)
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
    
    private func getTasksAndUpdateUI() {
        if !Bringg.shared.loginManager.isLoggedIn {
            notLoggedInView.isHidden = false
            return
        }
        
        notLoggedInView.isHidden = true
        
        Bringg.shared.tasksManager.getTasks { tasks, lastTimeTasksWereRefreshed, error in
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
        Bringg.shared.tasksManager.updateTasksPriorities(orderedTaskIds: taskIds, completion: { errorUpdatingPriorities in
            if let errorUpdatingPriorities = errorUpdatingPriorities {
                print("💣 \(errorUpdatingPriorities.localizedDescription)")
                return
            }
            print("🐧 updated task priorties completed")
        })
    }
}

// MARK: TaskViewControllerDelegate

extension TaskListViewController: TaskViewControllerDelegate {
    func taskViewControllerDidFinishTask(_ sender: TaskViewController) {
        self.navigationController?.popToViewController(self, animated: true)
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
