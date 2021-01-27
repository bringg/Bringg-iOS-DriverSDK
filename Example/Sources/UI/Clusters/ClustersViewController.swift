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
        tableView.refreshControl = self.refreshControl
        return tableView
    }()
    
    //State
    private var clusters: [Cluster] = []
    private var unclusteredTasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tasksTableView)
        tasksTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            
        }
        getTasksAndUpdateUI()
        Bringg.shared.loginManager.addDelegate(self)
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
    
    @objc private func refreshControlTriggered() {
        getTasksAndUpdateUI()
    }
}

//MARK: - UITableViewDataSource
extension ClustersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.cluster.rawValue:
            return clusters.count
        case Sections.unclusterTasks.rawValue:
            return unclusteredTasks.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Sections.cluster.rawValue:
            return clusterCell(tableView, atIndexPath: indexPath)
        case Sections.unclusterTasks.rawValue:
            return unclusteredTaskCell(tableView, atIndexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Sections.cluster.rawValue:
            return "Clusters"
        case Sections.unclusterTasks.rawValue:
            return "Unclustered Tasks"
        default:
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

