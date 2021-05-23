//
//  ClustersViewController.swift
//  BringgDriverSDKExample
//
//  Created by Ido Mizrachi on 26/08/2020.
//

import BringgDriverSDK
import UIKit
import SnapKit

final class ClustersViewController: UIViewController {
    enum Sections: Int, CaseIterable {
        case cluster = 0
        case unclusterTasks
        case breaks
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var tasksTableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ClusterCell.self, forCellReuseIdentifier: ClusterCell.cellIdentifier)
        tableView.register(TaskTableCellView.self, forCellReuseIdentifier: TaskTableCellView.cellIdentifier)
        tableView.register(BreakTableCellView.self, forCellReuseIdentifier: BreakTableCellView.cellIdentifier)
        tableView.refreshControl = self.refreshControl
        return tableView
    }()
    
    //State
    private var clusters: [Cluster] = []
    private var unclusteredTasks: [Task] = []
    private var breaks: [ScheduledBreak] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tasksTableView)

        tasksTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        getTasksAndUpdateUI()
        getBreaksAndUpdateUI()

        Bringg.shared.loginManager.addDelegate(self)
        Bringg.shared.breaksManager.addDelegate(self)
    }
    
    func getTasksAndUpdateUI() {
        self.refreshControl.beginRefreshing()
        Bringg.shared.tasksManager.getClusters { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let clusterAndTasks):
                self.clusters = clusterAndTasks.clusters
                self.unclusteredTasks = clusterAndTasks.unclusteredTasks
            case .failure(let error):
                self.clusters = []
                self.unclusteredTasks = []
                self.showError("Failed to fetch clusters & tasks.\n\(error.localizedDescription)")
            }
            self.tasksTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    func getBreaksAndUpdateUI() {
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
    
    @objc private func refreshControlTriggered() {
        getTasksAndUpdateUI()
        getBreaksAndUpdateUI()
    }
}

//MARK: - UITableViewDataSource
extension ClustersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .cluster:
            return clusters.count
        case .unclusterTasks:
            return unclusteredTasks.count
        case .breaks:
            return breaks.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .cluster:
            return clusterCell(tableView, atIndexPath: indexPath)
        case .unclusterTasks:
            return unclusteredTaskCell(tableView, atIndexPath: indexPath)
        case .breaks:
            return breakCell(tableView, atIndexPath: indexPath)
        case .none:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .cluster:
            return "Clusters"
        case .unclusterTasks:
            return "Unclustered Tasks"
        case .breaks:
            return "Breaks"
        case .none:
            return nil
        }
    }
    
    private func clusterCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ClusterCell.cellIdentifier, for: indexPath)
        if let clusterCell = cell as? ClusterCell {
            clusterCell.update(cluster: clusters[indexPath.row])
        }
        return cell
    }
    
    private func unclusteredTaskCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableCellView.cellIdentifier, for: indexPath)
        if let taskCell = cell as? TaskTableCellView {
            taskCell.task = unclusteredTasks[indexPath.row]
        }
        return cell
    }

    private func breakCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BreakTableCellView.cellIdentifier, for: indexPath) as! BreakTableCellView
        let breakModel = breaks[indexPath.row]
        cell.breakModel = breakModel
        cell.onAction = { [weak self] in self?.breakActionPressed(breakModel) }
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ClustersViewController: UITableViewDelegate {
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case Sections.cluster.rawValue:
            break
        case Sections.unclusterTasks.rawValue:
            let task = unclusteredTasks[indexPath.row]
            let taskViewController = TaskViewController(task: task)
            taskViewController.delegate = self
            navigationController?.pushViewController(taskViewController, animated: true)
        default:
            break
        }
     }
}

// MARK: - TaskViewControllerDelegate
extension ClustersViewController: TaskViewControllerDelegate {
    func taskViewControllerDidCompleteTask() {
        self.navigationController?.popViewController(animated: true)
        self.getTasksAndUpdateUI()
    }
    
    func taskViewControllerDidUngroupTask() {
        self.navigationController?.popViewController(animated: true)
        self.getTasksAndUpdateUI()
    }
}

// MARK: - UserEventsDelegate
extension ClustersViewController: UserEventsDelegate {
    func userDidLogin() {
        self.clusters = []
        self.unclusteredTasks = []
        tasksTableView.reloadData()
        getTasksAndUpdateUI()
    }
    
    func userDidLogout() {
        self.clusters = []
        self.unclusteredTasks = []
        tasksTableView.reloadData()
    }
}

// MARK: - BreaksManagerDelegate
extension ClustersViewController: BreaksManagerDelegate {
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
