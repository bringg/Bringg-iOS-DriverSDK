//
//  TaskViewController.swift
//  BringgDriverSDKExample
//
//  Copyright © 2020 Bringg. All rights reserved.
//

import BringgDriverSDK
import Foundation
import FSPagerView
import SnapKit

protocol TaskViewControllerDelegate: AnyObject {
    func taskViewControllerDidCompleteTask()
}

class TaskViewController: UIViewController {
    weak var delegate: TaskViewControllerDelegate?

    private var task: Task {
        didSet { updateUI() }
    }
    let refreshTaskDebounce = Debounce(timeInterval: 1000)

    private var notLoggedInView = NotLoggedInView()

    private lazy var waypointsPagerView: FSPagerView = {
        let view = FSPagerView()
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        view.register(WaypointPageCell.self, forCellWithReuseIdentifier: WaypointPageCell.cellIdentifier)
        return view
    }()

    private lazy var waypointPageControl: UIPageControl = {
        let control = UIPageControl()
        control.backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        control.currentPageIndicatorTintColor = .blue
        control.pageIndicatorTintColor = .white
        control.isUserInteractionEnabled = false
        return control
    }()

    private lazy var acceptTaskView: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Accept task", for: .normal)
        button.addTarget(self, action: #selector(acceptTaskButtonPressed(_:)), for: .touchUpInside)
        button.isHidden = true
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    private var waypointPageControlHeightConstraint: Constraint?

    init(task: Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
        self.title = "#\(task.externalId ?? "\(task.id)")"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        Bringg.shared.loginManager.addDelegate(self)
        Bringg.shared.tasksManager.addDelegate(self)

        view.addSubview(waypointPageControl)
        view.addSubview(waypointsPagerView)
        view.addSubview(acceptTaskView)
        view.addSubview(notLoggedInView)

        makeConstraints()
        updateUI()
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let activeWaypointId = task.activeWaypointId, let indexOfActiveWaypoint = task.waypoints.firstIndex(where: { $0.id == activeWaypointId }) {
            waypointPageControl.currentPage = indexOfActiveWaypoint
            waypointsPagerView.scrollToItem(at: indexOfActiveWaypoint, animated: true)
        }
    }

    private func makeConstraints() {
        waypointPageControl.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)

            waypointPageControlHeightConstraint = make.height.equalTo(0).constraint
        }

        waypointsPagerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(waypointPageControl.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        acceptTaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        notLoggedInView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func refreshTask() {
        refreshTaskDebounce.debounce { [weak self] in
            guard let self = self else { return }
            Bringg.shared.tasksManager.getTask(withTaskId: self.task.id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.showError(error.localizedDescription)
                case .success(.task(let task)):
                    self.task = task
                case .success(.taskNotAccessible):
                    self.showError("Task is no longet accessible to the current driver")
                }
            }
        }
    }

    private func updateUI() {
        self.notLoggedInView.isHidden = Bringg.shared.loginManager.currentUser != nil

        let shouldShowAcceptTaskOverlay = task.status == .assigned || task.status == .free
        self.acceptTaskView.isHidden = !shouldShowAcceptTaskOverlay

        waypointsPagerView.reloadData()

        waypointPageControl.numberOfPages = task.waypoints.count

        let shouldDisplayPageControlOnTopOfWaypointsPagedView = task.waypoints.count > 1
        if shouldDisplayPageControlOnTopOfWaypointsPagedView {
            self.waypointPageControlHeightConstraint?.deactivate()
        } else {
            self.waypointPageControlHeightConstraint?.activate()
        }
    }

    @objc func acceptTaskButtonPressed(_ sender: UIButton) {
        Bringg.shared.tasksManager.acceptTask(taskId: task.id) { error in
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }

            self.refreshTask()
        }
    }
}

// MARK: FSPagerViewDataSource, FSPagerViewDelegate

extension TaskViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        task.waypoints.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: WaypointPageCell.cellIdentifier, at: index)
        guard let waypointPageCell = cell as? WaypointPageCell else {
            return cell
        }

        let waypoint = task.waypoints[index]

        waypointPageCell.waypoint = waypoint
        waypointPageCell.task = task
        waypointPageCell.waypointInventoryArray = waypoint.inventoryItems

        waypointPageCell.delegate = self

        return cell
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        waypointPageControl.currentPage = targetIndex
    }
}

// MARK: WaypointPageCellDelegate

extension TaskViewController: WaypointPageCellDelegate {
    func waypointPageCell(_ cell: WaypointPageCell, startWaypointPressed forWaypoint: Waypoint) {
        let taskId = forWaypoint.taskId
        
        Bringg.shared.tasksManager.startTask(with: taskId) { result in
            switch result {
            case .success:
                self.refreshTask()
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        }
    }

    func waypointPageCell(_ cell: WaypointPageCell, arriveAtWaypointPressed forWaypoint: Waypoint) {
        Bringg.shared.tasksManager.arriveAtWaypoint(with: forWaypoint.id) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            self.refreshTask()
        }
    }

    func waypointPageCell(_ cell: WaypointPageCell, completeWaypointPressed forWaypoint: Waypoint) {
        Bringg.shared.tasksManager.leaveWaypoint(with: forWaypoint.id) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            self.refreshTask()

            if let indexOfWaypoint = self.task.waypoints.firstIndex(of: forWaypoint), indexOfWaypoint < self.task.waypoints.count {
                self.waypointsPagerView.scrollToItem(at: self.waypointsPagerView.currentIndex + 1, animated: true)
                self.waypointPageControl.currentPage += 1
            } else {
                self.delegate?.taskViewControllerDidCompleteTask()
            }
        }
    }

    func waypointPageCell(_ cell: WaypointPageCell, inventoryPressed: TaskInventory) {
        guard let waypoint = cell.waypoint else { return }
        let inventoryViewController = InventoryViewController(task: task, waypoint: waypoint) //Rename delegate
        navigationController?.pushViewController(inventoryViewController, animated: true)
    }
}

// MARK: UserEventsDelegate

extension TaskViewController: UserEventsDelegate {
    func userDidLogin() {
        updateUI()
    }

    func userDidLogout() {
        updateUI()
    }
}

// MARK: TasksManagerDelegate

extension TaskViewController: TasksManagerDelegate {
    func tasksManagerDidRefreshTaskList(_ tasksManager: TasksManagerProtocol) {
        refreshTask()
    }

    func tasksManager(_ tasksManager: TasksManagerProtocol, didAddNewTask taskId: Int) {
        refreshTask()
    }

    func tasksManager(_ tasksManager: TasksManagerProtocol, didUpdateTask taskId: Int) {
        refreshTask()
    }

    func tasksManager(_ tasksManager: TasksManagerProtocol, didAutoStartTask taskId: Int) { }
    
    func tasksManager(_ tasksManager: TasksManagerProtocol, didRemoveTask task: Task) {
        if task.id == self.task.id {
            refreshTaskDebounce.debounce { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func tasksManager(_ tasksManager: TasksManagerProtocol, didMassRemoveTasks tasks: [Task]) {
        refreshTask()
    }
}
