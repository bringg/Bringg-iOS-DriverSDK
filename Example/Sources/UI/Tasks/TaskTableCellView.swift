//
//  TaskTableCellView.swift
//  BringgDriverApp
//
//  Created by Ido Mizrachi on 30/08/2020.
//
import BringgDriverSDKObjc
import UIKit

class TaskTableCellView: UITableViewCell {
    static let cellIdentifier = "TaskTableCellViewCellIdentifier"
    
    var task: Task? {
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
