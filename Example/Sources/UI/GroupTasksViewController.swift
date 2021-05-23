//
//  GroupTasksViewController.swift
//  BringgDriverSDKExample
//
//  Created by Ido Mizrachi on 04/11/2020.
//

import BringgDriverSDK
import UIKit
import SnapKit


protocol GroupTasksViewControllerDelegate: class {
    func groupTasksViewControllerDidCreateGroup()
}

class GroupTasksViewController: UIViewController {
    
    struct Consts {
        static let groupTaskCellIdentifier = "groupTaskCell"
    }

    weak var delegate: GroupTasksViewControllerDelegate?
    var tasks: [Task] = []
    
    private func createButton(title: String, selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 6
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    lazy var groupButton = createButton(title: "Group", selector: #selector(groupButtonPressed))
    
    lazy var tasksTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(GroupTaskCell.self, forCellReuseIdentifier: Consts.groupTaskCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        return tableView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(tasksTableView)
        view.addSubview(groupButton)
        setupConstraints()
        
        Bringg.shared.tasksManager.getTasks { [weak self] tasks, _, error in
            guard let self = self else { return }
            guard let tasks = tasks else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.tasks = tasks
            self.tasksTableView.reloadData()
        }
    }
    
    private func setupConstraints() {
        tasksTableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        groupButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.top.equalTo(tasksTableView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(50)
        }
    }
    
    @objc private func groupButtonPressed() {
        let selectedRows = tasksTableView.indexPathsForSelectedRows ?? []
        let selectedTaskIds = selectedRows.map { tasks[$0.row].id }
        Bringg.shared.tasksManagerInternal.groupTasks(taskIds: selectedTaskIds) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("Failed to group tasks \(selectedTaskIds), error: \(error)")
            case .success(let task):
                print("Tasks \(selectedTaskIds) grouped successfully, grouped task:\n\(task)")
            }
            self.delegate?.groupTasksViewControllerDidCreateGroup()
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension GroupTasksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Consts.groupTaskCellIdentifier, for: indexPath)
        if let groupTaskCell = cell as? GroupTaskCell {
            groupTaskCell.task = tasks[indexPath.row]
        }
        return cell
    }
}

extension GroupTasksViewController {
    fileprivate class GroupTaskCell: UITableViewCell {
        var task: Task? {
            didSet {
                if let task = self.task {
                    taskIdLabel.text = String(task.id)
                    taskTitleLabel.text = task.title
                } else {
                    taskIdLabel.text = ""
                    taskTitleLabel.text = ""
                }
            }
        }
        
        lazy var taskIdLabel: UILabel = {
            let label = UILabel()
            return label
        }()
        
        lazy var taskTitleLabel: UILabel = {
            let label = UILabel()
            return label
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.addSubview(taskIdLabel)
            contentView.addSubview(taskTitleLabel)
            setupConstraints()
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        
        private func setupConstraints() {
            taskIdLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
            }
            taskTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(taskIdLabel.snp.bottom).offset(10)
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.bottom.equalToSuperview().offset(-10)
            }
        }
    }
}
