//
//  Copyright © 2018 Bringg. All rights reserved.
//

import BringgDriverSDK
import Foundation
import FSPagerView
import SnapKit

private enum WaypointActionButtonState {
    case startWaypoint
    case arriveAtWaypoint
    case completeWaypoint
    case isDone
    case isCancelled
}

private extension WaypointStatus {
    func waypointActionButtonState() -> WaypointActionButtonState {
        switch self {
        case .invalid: return .isCancelled
        case .pending: return .startWaypoint
        case .started: return .arriveAtWaypoint
        case .checkedIn: return .completeWaypoint
        case .done: return .isDone
        }
    }
}

protocol WaypointPageCellDelegate: class {
    func waypointPageCell(_ cell: WaypointPageCell, startWaypointPressed forWaypoint: Waypoint)
    func waypointPageCell(_ cell: WaypointPageCell, arriveAtWaypointPressed forWaypoint: Waypoint)
    func waypointPageCell(_ cell: WaypointPageCell, completeWaypointPressed forWaypoint: Waypoint)
}

class WaypointPageCell: FSPagerViewCell, UITableViewDelegate, UITableViewDataSource {
    private enum Sections: Int {
        case waypointDetails
        case inventoryItems
        case waypointNotes

        static func numberOfSections() -> Int { return Sections.waypointNotes.rawValue + 1 }
    }

    private enum WaypointDetailsCells: Int {
        case address
        case customer

        static func numberOfCells() -> Int { return WaypointDetailsCells.customer.rawValue + 1 }
    }

    var waypoint: Waypoint? {
        didSet { updateUIDependingOnWaypoint() }
    }
    var isCurrentWaypoint: Bool = false {
        didSet { updateUIDependingOnWaypoint() }
    }
    var waypointInventoryArray: [TaskInventory]? = nil {
        didSet { updateUIDependingOnWaypoint() }
    }
    var waypointNotesArray: [Note]? = nil {
        didSet { updateUIDependingOnWaypoint() }
    }

    weak var delegate: WaypointPageCellDelegate?

    static let cellIdentifier = "WaypointPageCellIndentifier"
    private let waypointDataTableViewCellIdentifier = "waypointDataTableViewCellIdentifier"

    //Views

    private lazy var waypointDataTableView: UITableView = {
        let tableView = UITableView(frame: self.bounds, style: .grouped)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: waypointDataTableViewCellIdentifier)
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
        guard let waypoint = self.waypoint else { return }

        switch waypoint.status.waypointActionButtonState() {
        case .startWaypoint: self.delegate?.waypointPageCell(self, startWaypointPressed: waypoint)
        case .arriveAtWaypoint: self.delegate?.waypointPageCell(self, arriveAtWaypointPressed: waypoint)
        case .completeWaypoint: self.delegate?.waypointPageCell(self, completeWaypointPressed: waypoint)
        case .isDone, .isCancelled: break
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
        if !isCurrentWaypoint {
            return "PENDING"
        }
        guard let actionButtonState = self.waypoint?.status.waypointActionButtonState() else {
            return ""
        }
        switch actionButtonState {
        case .startWaypoint: return "START ORDER"
        case .arriveAtWaypoint: return "ARRIVED"
        case .completeWaypoint: return "COMPLETE ORDER"
        case .isDone: return "COMPLETED"
        case .isCancelled: return "CANCELLED"
        }
    }

    func shouldWaypointActionButtonBeEnabled() -> Bool {
        if !isCurrentWaypoint {
            return false
        }
        guard let actionButtonState = self.waypoint?.status.waypointActionButtonState() else {
            return false
        }
        switch actionButtonState {
        case .startWaypoint, .arriveAtWaypoint, .completeWaypoint: return true
        case .isDone, .isCancelled: return false
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
        case .waypointNotes:
            let numberOfWaypointNotes = waypointNotesArray?.count ?? 0
            return numberOfWaypointNotes > 0 ? "Notes" : nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else { return 0 }
        switch section {
        case .waypointDetails:
            return WaypointDetailsCells.numberOfCells()
        case .inventoryItems:
            return waypointInventoryArray?.count ?? 0
        case .waypointNotes:
            return waypointNotesArray?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Sections(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .waypointDetails:
            return self.tableView(tableView, cellForWaypointDetailsAtIndexPath: indexPath)
        case .inventoryItems:
            return self.tableView(tableView, cellForInventoryAtIndexPath: indexPath)
        case .waypointNotes:
            return self.tableView(tableView, cellForNoteAtIndexPath: indexPath)
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

    private func tableView(_ tableView: UITableView, cellForNoteAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: waypointDataTableViewCellIdentifier, for: indexPath)
        cell.selectionStyle = .none

        guard let note = self.waypointNotesArray?[indexPath.row] else { return cell }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = note.note

        return cell
    }
}
