//
//  WaypointPageCell.swift
//  BringgDriverSDK_Example
//
//  Created by Michael Tzach on 15/04/2018.
//  Copyright © 2018 Bringg. All rights reserved.
//

import BringgDriverSDK
import Foundation
import FSPagerView
import SnapKit

private enum WaypointActionButtonState {
    case pending
    case startWaypoint
    case arriveAtWaypoint
    case completeWaypoint
    case isDone
    case isCancelled
}

protocol WaypointPageCellDelegate: class {
    func waypointPageCell(_ cell: WaypointPageCell, startWaypointPressed forWaypoint: Waypoint)
    func waypointPageCell(_ cell: WaypointPageCell, arriveAtWaypointPressed forWaypoint: Waypoint)
    func waypointPageCell(_ cell: WaypointPageCell, completeWaypointPressed forWaypoint: Waypoint)
    func waypointPageCell(_ cell: WaypointPageCell, inventoryPressed: TaskInventory)
}

class WaypointPageCell: FSPagerViewCell, UITableViewDelegate, UITableViewDataSource {
    private enum Sections: Int, CaseIterable {
        case waypointDetails
        case inventoryItems
        case phoneNumber

        static func numberOfSections() -> Int { return Sections.allCases.count }
    }

    private enum WaypointDetailsCells: Int, CaseIterable {
        case address
        case customer

        static func numberOfCells() -> Int { return WaypointDetailsCells.allCases.count }
    }

    private enum PhoneNumberCells: Int, CaseIterable {
        case phoneAvailable
        case phoneData

        static func numberOfCells() -> Int { return PhoneNumberCells.allCases.count }
    }

    var waypoint: Waypoint? {
        didSet { updateUIDependingOnWaypoint() }
    }
    var task: Task? {
        didSet { updateUIDependingOnWaypoint() }
    }
    var waypointInventoryArray: [TaskInventory]? = nil {
        didSet { updateUIDependingOnWaypoint() }
    }

    weak var delegate: WaypointPageCellDelegate?

    static let cellIdentifier = "WaypointPageCellIndentifier"
    private let waypointDataTableViewCellIdentifier = "waypointDataTableViewCellIdentifier"
    private let phoneNumberCellIdentifier = "phoneNumberCellIdentifier"

    private func waypointActionButtonState() -> WaypointActionButtonState? {
        guard let waypoint = waypoint, let task = task else {
            return nil
        }

        if let doneValue = waypoint.done, doneValue == true {
            return .isDone
        }

        let isActiveWaypoint = waypoint.id == task.activeWaypointId
        if !isActiveWaypoint {
            return .pending
        }

        switch task.status {
        case .accepted: return .startWaypoint
        case .assigned, .free, .invalid: return .isCancelled //This should never happen. This cell should be displayed after the task has been accepted
        case .cancelled: return .isCancelled
        case .checkedIn: return .completeWaypoint
        case .checkedOut: return .isDone
        case .onTheWay: return .arriveAtWaypoint
        }
    }

    //Views

    private lazy var waypointDataTableView: UITableView = {
        let tableView = UITableView(frame: self.bounds, style: .grouped)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: waypointDataTableViewCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: phoneNumberCellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear

        return tableView
    }()

    private lazy var waypointActionsBarBackgroungView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.backgroundColor = .lightGray
        return view
    }()

    private lazy var waypointActionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(waypointActionButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = 3
        return button
    }()

    @objc private func waypointActionButtonPressed() {
        guard let waypoint = waypoint, let waypointActionButtonState = waypointActionButtonState() else { return }

        switch waypointActionButtonState {
        case .startWaypoint: self.delegate?.waypointPageCell(self, startWaypointPressed: waypoint)
        case .arriveAtWaypoint: self.delegate?.waypointPageCell(self, arriveAtWaypointPressed: waypoint)
        case .completeWaypoint: self.delegate?.waypointPageCell(self, completeWaypointPressed: waypoint)
        case .pending, .isDone, .isCancelled: break
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addSubview(waypointDataTableView)
        addSubview(waypointActionsBarBackgroungView)
        waypointActionsBarBackgroungView.addSubview(waypointActionButton)

        makeConstraints()
    }

    private func makeConstraints() {
        waypointDataTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(waypointActionsBarBackgroungView.snp.top)
        }

        waypointActionsBarBackgroungView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        waypointActionButton.snp.makeConstraints { make in
            make.leading.equalTo(waypointActionsBarBackgroungView).offset(8)
            make.top.equalTo(waypointActionsBarBackgroungView).offset(8)
            make.bottom.equalTo(waypointActionsBarBackgroungView).offset(-16)
            make.trailing.equalTo(waypointActionsBarBackgroungView).offset(-8)
        }
    }

    func waypointActionButtonText() -> String {
        guard let actionButtonState = waypointActionButtonState() else {
            return ""
        }
        switch actionButtonState {
        case .startWaypoint: return "START ORDER"
        case .arriveAtWaypoint: return "ARRIVED"
        case .completeWaypoint: return "COMPLETE ORDER"
        case .isDone: return "COMPLETED"
        case .isCancelled: return "CANCELLED"
        case .pending: return "PENDING"
        }
    }

    func shouldWaypointActionButtonBeEnabled() -> Bool {
        guard let actionButtonState = waypointActionButtonState() else {
            return false
        }
        switch actionButtonState {
        case .startWaypoint, .arriveAtWaypoint, .completeWaypoint: return true
        case .isDone, .isCancelled, .pending: return false
        }
    }

    private func updateUIDependingOnWaypoint() {
        waypointActionButton.setTitle(waypointActionButtonText(), for: .normal)
        waypointActionButton.isUserInteractionEnabled = shouldWaypointActionButtonBeEnabled()
        waypointActionButton.backgroundColor = shouldWaypointActionButtonBeEnabled() ? .blue : .darkGray

        waypointDataTableView.reloadData()
    }

    // MARK: UITableViewDelegate, UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.numberOfSections()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }

        switch section {
        case .waypointDetails:
            return "Waypoint details"
        case .inventoryItems:
            let numberofInventoryItems = waypointInventoryArray?.count ?? 0
            return numberofInventoryItems > 0 ? "Inventory" : nil
        case .phoneNumber:
            return "Phone Number"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else { return 0 }
        switch section {
        case .waypointDetails:
            return WaypointDetailsCells.numberOfCells()
        case .inventoryItems:
            return waypointInventoryArray?.count ?? 0
        case .phoneNumber:
            return PhoneNumberCells.numberOfCells()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Sections(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .waypointDetails:
            return self.tableView(tableView, cellForWaypointDetailsAtIndexPath: indexPath)
        case .inventoryItems:
            return self.tableView(tableView, cellForInventoryAtIndexPath: indexPath)
        case .phoneNumber:
            return self.tableView(tableView, cellForPhoneNumberAtIndexPath: indexPath)
        }
    }

    private func tableView(_ tableView: UITableView, cellForWaypointDetailsAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: waypointDataTableViewCellIdentifier, for: indexPath)
        cell.selectionStyle = .none

        guard let detailCase = WaypointDetailsCells(rawValue: indexPath.row) else { return cell }
        switch detailCase {
        case .address:
            cell.textLabel?.text = "Address: \(waypoint?.address ?? "")"
        case .customer:
            cell.textLabel?.text = "Customer: \(waypoint?.customer?.name ?? "")"
        }

        return cell
    }

    private func tableView(_ tableView: UITableView, cellForInventoryAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: waypointDataTableViewCellIdentifier, for: indexPath)
        cell.selectionStyle = .none

        guard let inventoryItem = self.waypointInventoryArray?[indexPath.row] else { return cell }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = inventoryItem.name

        return cell
    }

    private func tableView(_ tableView: UITableView, cellForPhoneNumberAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: phoneNumberCellIdentifier, for: indexPath)
        cell.selectionStyle = .none

        guard let cellType = PhoneNumberCells(rawValue: indexPath.row) else { return cell }
        switch cellType {
        case .phoneAvailable:
            let phoneAvailableString: String
            if let phoneAvailable = waypoint?.phoneAvailable {
                phoneAvailableString = String(phoneAvailable)
            } else {
                phoneAvailableString = "unknown"
            }
            cell.textLabel?.text = "Phone Available: \(phoneAvailableString)"
        case .phoneData:
            if let phoneNumber = waypoint?.customer?.phone {
                cell.textLabel?.text = phoneNumber
            } else {
                cell.textLabel?.text = "Get Phone Number"
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Sections(rawValue: indexPath.section) else { return }
        switch section {
        case .waypointDetails: break
        case .inventoryItems:
            guard let inventoryItem = waypointInventoryArray?[indexPath.row] else { return }
            delegate?.waypointPageCell(self, inventoryPressed: inventoryItem)
        case .phoneNumber:
            self.tableView(tableView, didSelectPhoneNumberCellAtIndexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didSelectPhoneNumberCellAtIndexPath indexPath: IndexPath) {
        guard let cellType = PhoneNumberCells(rawValue: indexPath.row) else { return }
        switch cellType {
        case .phoneAvailable:
            break   //nothing to do
        case .phoneData:
            guard let taskId = task?.id, let waypointId = waypoint?.id else { return }
            guard waypoint?.phoneAvailable == true else {
                logInfo("Phone is not available, no need to fetch from the server")
                return
            }
            guard waypoint?.customer?.phone == nil else {
                return
            }
            Bringg.shared.tasksManager.getMaskedPhoneNumber(taskId: taskId, waypointId: waypointId) { result in
                let cell = tableView.cellForRow(at: indexPath)
                switch result {
                case .success(let phoneNumber):
                    cell?.textLabel?.text = phoneNumber
                case .failure(let error):
                    logError("Failed to get masked phone number for task:\(taskId), waypoint: \(waypointId), error: \(error.localizedDescription)")
                    cell?.textLabel?.text = error.localizedDescription
                }
            }
        }

    }
}
