//
//  ClusterCell.swift
//  BringgDriverSDKExample
//
//  Created by Ido Mizrachi on 27/08/2020.
//

import BringgDriverSDK
import UIKit
import SnapKit

extension ClustersViewController {
    
    final class ClusterCell: UITableViewCell {
        static let cellIdentifier = "ClusterCellIdentifier"
        
        private lazy var headerView: ClusterHeaderView = {
            let headerView = ClusterHeaderView()
            return headerView
        }()
        
        private lazy var tasksView: ClusterTasksView = {
            let tasksView = ClusterTasksView()
            return tasksView
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            addSubview(headerView)
            addSubview(tasksView)
            makeConstraints()
        }
        
        func update(cluster: Cluster) {
            headerView.update(title: "Cluster with \(cluster.clusteredTasks.count) orders")
            tasksView.update(cluster: cluster)
        }
        
        private func createTaskView(_ clusteredTask: Cluster.ClusteredTask) -> UIView {
            let label = UILabel()
            label.text = "\(clusteredTask.task.id) - \(clusteredTask.task.title ?? "")"
            return label
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        private func makeConstraints() {
            headerView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
            }
            tasksView.snp.makeConstraints { make in
                make.top.equalTo(headerView.snp.bottom).offset(8)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }
}

extension ClustersViewController.ClusterCell {
    private class ClusterHeaderView: UIView {
        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 1
            return label
        }()
        
        init() {
            super.init(frame: .zero)
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15))
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func update(title: String) {
            titleLabel.text = title
        }
    }
    
    private class ClusterTasksView: UIView {
        private lazy var tasksStackView: UIStackView  = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            return stackView
        }()
        
        init() {
            super.init(frame: .zero)
            addSubview(tasksStackView)
            tasksStackView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15))
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func update(cluster: Cluster) {
            reset()
            cluster.clusteredTasks.forEach {
                let taskView = ClusterTaskView()
                taskView.update(clusteredTask: $0)
                tasksStackView.addArrangedSubview(taskView)
            }
        }
        
        private func reset() {
            let arrangedSubviews  = tasksStackView.arrangedSubviews
            arrangedSubviews.forEach {
                $0.removeFromSuperview()
            }
        }
    }
    
    private class ClusterTaskView: UIView {
        lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 1
            label.textColor = .black
            return label
        }()
        
        lazy var externalIdLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 1
            label.textColor = .black
            return label
        }()
        
        lazy var addressLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = .gray
            return label
        }()
        
        init() {
            super.init(frame: .zero)
            addSubview(externalIdLabel)
            addSubview(titleLabel)
            addSubview(addressLabel)
            setupConstraints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupConstraints() {
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview()
                
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
            }
            externalIdLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
            }
            addressLabel.snp.makeConstraints { make in
                make.top.equalTo(externalIdLabel.snp.bottom).offset(8)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset(-8)
            }
        }
        
        func update(clusteredTask: Cluster.ClusteredTask) {
            titleLabel.text = clusteredTask.task.title ?? ""
            externalIdLabel.text = clusteredTask.task.externalId ?? ""
            addressLabel.text = clusteredTask.clusteredByWaypoint.address ?? ""
        }
    }
}
