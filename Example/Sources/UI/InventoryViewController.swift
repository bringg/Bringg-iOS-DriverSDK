//
//  InventoryViewController.swift
//  BringgDriverSDKExample
//
//  Copyright © 2020 Bringg. All rights reserved.
//

import BringgDriverSDK
import SnapKit
import UIKit

class InventoryViewController: UIViewController {
    private var task: Task?
    private var waypoint: Waypoint?
    private var viewModel: InventoryViewModel?

    private func dataChanged() {
        guard let taskId = task?.id, let waypointId = waypoint?.id else {
            return
        }
        Bringg.shared.tasksManager.getTask(withTaskId: taskId) { result in
            switch result {
            case .failure(let error):
                print("Failed to fetch task \(taskId), error: \(error)")
            case .success(.taskNotAccessible):
                print("Task is no longer accessible to the driver")
            case .success(.task(let task)):
                self.task = task
                self.waypoint = task.waypoints.first(where: { $0.id == waypointId })
                let inventories = self.waypoint?.inventoryItems
                let cellViewModels = inventories?.map { InventoryCellViewModel(taskInventory: $0) } ?? []
                self.viewModel = InventoryViewModel(cellViewModels: cellViewModels)
                self.tableView.reloadData()
            }
        }
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(InventoryCell.self, forCellReuseIdentifier: "InventoryCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()

    init(task: Task, waypoint: Waypoint) {
        self.task = task
        self.waypoint = waypoint
        let inventories = waypoint.inventoryItems
        let cellViewModels = inventories?.map { InventoryCellViewModel(taskInventory: $0) } ?? []
        self.viewModel = InventoryViewModel(cellViewModels: cellViewModels)
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .white
        title = "Edit Inventories"
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Bringg.shared.tasksManager.addDelegate(self)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension InventoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.cellViewModels.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell") as? InventoryCell, let viewModel = viewModel else {
            return UITableViewCell()
        }
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        cell.viewModel = cellViewModel
        return cell
    }
}

class InventoryCell: UITableViewCell {

    var viewModel: InventoryCellViewModel! {
        didSet {
            idLabel.text = "id: " + String(viewModel.taskInventory.id)
            nameLabel.text = "name: " + (viewModel.taskInventory.name ?? "")
            inventoryIdLabel.text = "inventory id: " + String(viewModel.taskInventory.inventoryId ?? -1)
            originalQuantityLabel.text = "original quantity: " + String(viewModel.taskInventory.originalQuantity ?? 0)
            scanStringLabel.text = "scan string: " + (viewModel.taskInventory.scanString ?? "")
            externalIdLabel.text = "external id: " + (viewModel.taskInventory.externalId ?? "")
            quantityValueLabel.text = String(viewModel.taskInventory.quantity ?? 0)
            quantityValueStepper.value = Double(viewModel.taskInventory.quantity ?? 0)
        }
    }

    lazy var nameLabel = UILabel()
    lazy var idLabel = UILabel()
    lazy var inventoryIdLabel = UILabel()
    lazy var originalQuantityLabel = UILabel()
    lazy var scanStringLabel = UILabel()
    lazy var externalIdLabel = UILabel()

    lazy var quantityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Quantity"
        label.textAlignment = .center
        return label
    }()

    lazy var quantityValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    lazy var quantityValueStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.addTarget(self, action: #selector(quantityChanged), for: .valueChanged)
        stepper.stepValue = 1.0
        stepper.minimumValue = -10_000_000
        stepper.maximumValue = 10_000_000
        return stepper
    }()

    lazy var leftStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.nameLabel,
            self.idLabel,
            self.inventoryIdLabel,
            self.originalQuantityLabel,
            self.scanStringLabel,
            self.externalIdLabel,
            UIView()    //padding
        ])
        stackView.axis = .vertical
        return stackView
    }()

    lazy var rightStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.quantityTitleLabel,
            self.quantityValueLabel,
            self.quantityValueStepper,
            UIView()    //padding
        ])
        stackView.axis = .vertical
        return stackView
    }()

    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.leftStackView, self.rightStackView])
        stackView.axis = .horizontal
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(containerStackView)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupConstraints() {
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }
    }

    @objc private func quantityChanged() {
        viewModel.newQuantity = Int(quantityValueStepper.value)
        self.quantityValueLabel.text = String(viewModel.newQuantity)
    }
}

class InventoryViewModel {
    let cellViewModels: [InventoryCellViewModel]

    init(cellViewModels: [InventoryCellViewModel]) {
        self.cellViewModels = cellViewModels
    }
}

class InventoryCellViewModel {
    let taskInventory: TaskInventory
    var newQuantity: Int

    init(taskInventory: TaskInventory) {
        self.taskInventory = taskInventory
        self.newQuantity = taskInventory.quantity ?? 0
    }
}

// MARK: - TasksManagerDelegate

extension InventoryViewController: TasksManagerDelegate {
    func tasksManagerDidRefreshTaskList(_ tasksManager: TasksManagerProtocol) {
        dataChanged()
    }

    func tasksManager(_ tasksManager: TasksManagerProtocol, didRemoveTask task: Task) {
        guard self.task?.id == task.id else {
            return
        }
        dataChanged()
    }

    func tasksManager(_ tasksManager: TasksManagerProtocol, didMassRemoveTasks tasks: [Task]) {
        dataChanged()
    }

    func tasksManager(_ tasksManager: TasksManagerProtocol, didUpdateTask taskId: Int) {
        guard self.task?.id == taskId else {
            return
        }
        dataChanged()
    }
    
    func tasksManager(_ tasksManager: TasksManagerProtocol, didAutoStartTask taskId: Int) { }

    func tasksManager(_ tasksManager: TasksManagerProtocol, didAddNewTask taskId: Int) { }
}
