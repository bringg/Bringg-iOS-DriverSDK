//
//  Copyright © 2018 Bringg. All rights reserved.
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
        case .rejected: return "rejected"
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

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(taskTitleLabel)
        addSubview(externalIdLabel)
        addSubview(statusAndAsapLabel)
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

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

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TasksEventsDelegate, UserEventsDelegate, TaskViewControllerDelegate {
    private enum Sections: Int {
        case tasks

        static func numberOfSections() -> Int {
            return Sections.tasks.rawValue + 1
        }
    }

    //Views

    private var notLoggedInView = NotLoggedInView()

    private lazy var tasksTableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlFired(_:)), for: .valueChanged)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getTasksAndUpdateUI()
    }

    private func getTasksAndUpdateUI() {
        if Bringg.shared.loginManager.currentUser == nil {
            notLoggedInView.isHidden = false
            return
        }

        notLoggedInView.isHidden = true

        Bringg.shared.tasksManager.getTasks { tasks, lastTimeTasksWereRefreshed in
            self.tasks = tasks
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

    @objc private func refreshControlFired(_ refreshControl: UIRefreshControl) {
        Bringg.shared.tasksManager.refreshTasks { tasks, error in
            refreshControl.endRefreshing()

            if let error = error {
                self.showError(error.localizedDescription)
                return
            }

            self.tasks = tasks
            self.tasksTableView.reloadData()
        }
    }

    // MARK: UITableViewDelegate, UITableViewDataSource

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

    // MARK: TaskViewControllerDelegate

    func taskViewControllerDidFinishTask(_ sender: TaskViewController) {
        self.navigationController?.popToViewController(self, animated: true)
    }

    // MARK: TasksManagerProtocol

    func tasksEventsProviderDidRefreshTaskList(_ taskStateProvider: TasksManagerProtocol) {
        getTasksAndUpdateUI()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didAddNewTask taskId: NSNumber) {
        getTasksAndUpdateUI()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didUpdateTask taskId: NSNumber) {
        getTasksAndUpdateUI()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didAddWaypoint waypointId: NSNumber) {
        getTasksAndUpdateUI()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didAddNote noteId: NSNumber) {
        getTasksAndUpdateUI()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didUpdateWaypoint waypointId: NSNumber) {
        getTasksAndUpdateUI()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didCompleteTask taskId: NSNumber) {
        getTasksAndUpdateUI()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didRemoveTask taskId: NSNumber) {
        getTasksAndUpdateUI()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didMassRemoveTasks taskIds: [NSNumber]) {
        getTasksAndUpdateUI()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didRemoveWaypoint waypointId: NSNumber) {
        getTasksAndUpdateUI()
    }

    // MARK: UserEventsDelegate

    func userDidLogin() {
        getTasksAndUpdateUI()
    }

    func userDidLogout() {
        getTasksAndUpdateUI()
    }
}
