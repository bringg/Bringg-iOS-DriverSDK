//
//  TaskViewController.swift
//  BringgDriverSDK_Example
//
//  Created by Michael Tzach on 15/04/2018.
//  Copyright © 2018 Bringg. All rights reserved.
//

import BringgDriverSDK
import Foundation
import FSPagerView
import SnapKit

protocol TaskViewControllerDelegate: class {
    func taskViewControllerDidFinishTask(_ sender: TaskViewController)
}

class TaskViewController: UIViewController, FSPagerViewDelegate, FSPagerViewDataSource, WaypointPageCellDelegate, UserEventsDelegate, TasksManagerDelegate {
    weak var delegate: TaskViewControllerDelegate?

    private var task: Task {
        didSet { updateUI() }
    }

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

    required init?(coder aDecoder: NSCoder) {
        fatalError("You must use the designated initializer init(task:) for this view controller")
    }

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
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            self.waypointPageControlHeightConstraint = make.height.equalTo(0).constraint
        }

        waypointsPagerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(waypointPageControl.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }

        acceptTaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        notLoggedInView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func refreshTask() {
        Bringg.shared.tasksManager.getTask(withTaskId: task.id) { task, error in
            if let error = error {
                self.showError(error.localizedDescription)
            }
            guard let task = task else { return }
            self.task = task
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

    // MARK: UserEventsDelegate

    func userDidLogin() {
        self.updateUI()
    }

    func userDidLogout() {
        self.updateUI()
    }

    // MARK: FSPagerViewDataSource, FSPagerViewDelegate

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return task.waypoints.count
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

    // MARK: WaypointPageCellDelegate

    func waypointPageCell(_ cell: WaypointPageCell, startWaypointPressed forWaypoint: Waypoint) {
        let taskId = forWaypoint.taskId ?? self.task.id
        
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
        Bringg.shared.tasksManager.arriveAtWaypoint(with: forWaypoint.id) { error in
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            self.refreshTask()
        }
    }

    func waypointPageCell(_ cell: WaypointPageCell, completeWaypointPressed forWaypoint: Waypoint) {
        Bringg.shared.tasksManager.leaveWaypoint(with: forWaypoint.id) { error in
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            self.refreshTask()

            if let indexOfWaypoint = self.task.waypoints.firstIndex(of: forWaypoint), indexOfWaypoint < self.task.waypoints.count {
                self.waypointsPagerView.scrollToItem(at: self.waypointsPagerView.currentIndex + 1, animated: true)
                self.waypointPageControl.currentPage += 1
            } else {
                self.delegate?.taskViewControllerDidFinishTask(self)
            }
        }
    }

    func waypointPageCell(_ cell: WaypointPageCell, inventoryPressed: TaskInventory) {
        guard let waypoint = cell.waypoint else { return }
        let inventoryViewController = InventoryViewController(task: task, waypoint: waypoint) //Rename delegate
        navigationController?.pushViewController(inventoryViewController, animated: true)
        
    }

    // MARK: TasksManagerDelegate

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
        refreshTask()
    }

    func tasksManager(_ tasksManager: TasksManagerProtocol, didMassRemoveTasks tasks: [Task]) {
        refreshTask()
    }
}
