//
//  Copyright © 2018 Bringg. All rights reserved.
//

import BringgDriverSDK
import Foundation
import FSPagerView
import SnapKit

protocol TaskViewControllerDelegate: class {
    func taskViewControllerDidFinishTask(_ sender: TaskViewController)
}

class TaskViewController: UIViewController, FSPagerViewDelegate, FSPagerViewDataSource, WaypointPageCellDelegate, UserEventsDelegate, TasksEventsDelegate {
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
        view.addSubview(notLoggedInView)

        makeConstraints()
        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let activeWaypointId = task.activeWaypointId, let indexOfActiveWaypoint = task.waypoints.index(where: { $0.id == activeWaypointId }) {
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
                make.top.equalToSuperview()
            }
        }

        notLoggedInView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func refreshTask() {
        Bringg.shared.tasksManager.getTask(with: task.id) { task in
            guard let task = task else { return }
            self.task = task
        }
    }

    private func updateUI() {
        self.notLoggedInView.isHidden = Bringg.shared.loginManager.currentUser != nil

        waypointsPagerView.reloadData()

        waypointPageControl.numberOfPages = task.waypoints.count

        let shouldDisplayPageControlOnTopOfWaypointsPagedView = task.waypoints.count > 1
        if shouldDisplayPageControlOnTopOfWaypointsPagedView {
            self.waypointPageControlHeightConstraint?.deactivate()
        } else {
            self.waypointPageControlHeightConstraint?.activate()
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
        waypointPageCell.isCurrentWaypoint = task.activeWaypointId == waypoint.id
        waypointPageCell.waypointInventoryArray = task.taskInventories.filter { $0.waypointId == waypoint.id }
        waypointPageCell.waypointNotesArray = task.notes.filter { $0.waypointId == waypoint.id }

        waypointPageCell.delegate = self

        return cell
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        waypointPageControl.currentPage = targetIndex
    }

    // MARK: WaypointPageCellDelegate

    func waypointPageCell(_ cell: WaypointPageCell, startWaypointPressed forWaypoint: Waypoint) {
        let taskId = forWaypoint.taskId ?? self.task.id

        Bringg.shared.tasksManager.startTask(with: taskId) { error in
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            self.refreshTask()
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
        Bringg.shared.tasksManager.leaveWaypoint(with: forWaypoint.id) { nextWaypointId, error in
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            self.refreshTask()

            if nextWaypointId != nil {
                self.waypointsPagerView.scrollToItem(at: self.waypointsPagerView.currentIndex + 1, animated: true)
                self.waypointPageControl.currentPage += 1
            } else {
                self.delegate?.taskViewControllerDidFinishTask(self)
            }
        }
    }

    // MARK: TasksEventsDelegate
    func tasksEventsProviderDidRefreshTaskList(_ taskStateProvider: TasksManagerProtocol) {
        refreshTask()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didAddNewTask taskId: NSNumber) {
        refreshTask()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didUpdateTask taskId: NSNumber) {
        refreshTask()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didAddWaypoint waypointId: NSNumber) {
        refreshTask()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didAddNote noteId: NSNumber) {
        refreshTask()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didUpdateWaypoint waypointId: NSNumber) {
        refreshTask()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didCompleteTask taskId: NSNumber) {
        refreshTask()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didRemoveTask taskId: NSNumber) {
        refreshTask()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didMassRemoveTasks taskIds: [NSNumber]) {
        refreshTask()
    }

    func tasksEventsProvider(_ tasksEventsProvider: TasksManagerProtocol, didRemoveWaypoint waypointId: NSNumber) {
        refreshTask()
    }
}
