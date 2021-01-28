//
//  ShiftViewController.swift
//  BringgDriverSDKExample
//
//  Copyright © 2020 Bringg. All rights reserved.
//

import BringgDriverSDK
import SnapKit
import UIKit

class ShiftViewController: UIViewController, UserEventsDelegate, ShiftManagerDelegate {
    private var notLoggedInView = NotLoggedInView()

    private lazy var currentShiftStateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private lazy var startShiftButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Start shift", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(startShiftButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var endShiftButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("End shift", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(endShiftButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var showShiftHistoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Show shift history", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(showShiftHistoryButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

    private var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    private var endShiftInitiatedFromClient = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        Bringg.shared.loginManager.addDelegate(self)
        Bringg.shared.shiftManager.addDelegate(self)

        view.addSubview(currentShiftStateLabel)
        view.addSubview(startShiftButton)
        view.addSubview(endShiftButton)
        view.addSubview(showShiftHistoryButton)
        view.addSubview(activityIndicatorView)
        view.addSubview(notLoggedInView)

        makeConstraints()

        setViewVisabilityDependingOnLoginState()
        setViewTextAndEnabledDependingOnIsOnShiftState()
    }

    private func makeConstraints() {
        notLoggedInView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        currentShiftStateLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview().offset(15)
            make.trailing.lessThanOrEqualToSuperview().offset(-15)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.centerX.equalToSuperview()
        }

        startShiftButton.snp.makeConstraints { make in
            make.top.equalTo(currentShiftStateLabel.snp.bottom).offset(30)
            make.leading.greaterThanOrEqualToSuperview().offset(15)
            make.trailing.lessThanOrEqualToSuperview().offset(-15)
            make.centerX.equalToSuperview()
        }

        endShiftButton.snp.makeConstraints { make in
            make.top.equalTo(startShiftButton.snp.bottom).offset(10)
            make.leading.greaterThanOrEqualToSuperview().offset(15)
            make.trailing.lessThanOrEqualToSuperview().offset(-15)
            make.centerX.equalToSuperview()
        }

        showShiftHistoryButton.snp.makeConstraints { make in
            make.top.equalTo(endShiftButton.snp.bottom).offset(10)
            make.leading.greaterThanOrEqualToSuperview().offset(15)
            make.trailing.lessThanOrEqualToSuperview().offset(-15)
            make.centerX.equalToSuperview()
        }

        activityIndicatorView.snp.makeConstraints { make in
            make.top.equalTo(showShiftHistoryButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    private var isLoggedIn: Bool { Bringg.shared.loginManager.isLoggedIn }
    private var isOnShift: Bool { Bringg.shared.shiftManager.isOnShift }

    private func setViewVisabilityDependingOnLoginState() {
        if isLoggedIn {
            notLoggedInView.isHidden = true
        } else {
            notLoggedInView.isHidden = false
        }
    }

    private func setViewTextAndEnabledDependingOnIsOnShiftState() {
        if isOnShift {
            startShiftButton.isEnabled = false
            endShiftButton.isEnabled = true
            currentShiftStateLabel.text = "STATUS: on shift"
        } else {
            startShiftButton.isEnabled = true
            endShiftButton.isEnabled = false
            currentShiftStateLabel.text = "STATUS: off shift"
        }
    }

    @objc private func startShiftButtonPressed(_ sender: UIButton) {
        activityIndicatorView.startAnimating()
        Bringg.shared.shiftManager.startShift() { result in
            self.activityIndicatorView.stopAnimating()

            switch result {
            case .success:
                print("Started shift")
                self.setViewTextAndEnabledDependingOnIsOnShiftState()
            case .failure(let startShiftError):
                switch startShiftError {
                case .notAllMandatoryActionsAreFulfilled, .generalError, .startShiftCalledWhileShiftOperationInProgress:
                    self.showError("Error starting shift \(startShiftError)")
                case .stateErrorFromTheServer(let shiftStateError):
                    switch shiftStateError {
                    case .none:
                        self.handleShiftStartFailedDueToErrorWithForceStartOption(message: "Shift couldn't be started for an unknown reason")
                    case .alreadyExists:
                        self.handleShiftStartFailedDueToErrorWithForceStartOption(message: "Shift already exists")
                    case .alreadyExistsOnDifferentDevice:
                        self.handleShiftStartFailedDueToErrorWithForceStartOption(message: "Shift already exists on different device")
                    case .notAllowedDueToDistanceFromHome:
                        self.handleShiftStartFailedDueToErrorWithForceStartOption(message: "Shift start not allowed due to distance from home")
                    case .notAllowedDueToScheduleTimeOfDay:
                        self.handleShiftStartFailedDueToErrorWithForceStartOption(message: "Shift start not allowed due to schedule time of day")
                    case .notAllowedDueToDistanceFromScheduleHomeAndTimeOfDay:
                        self.handleShiftStartFailedDueToErrorWithForceStartOption(message: "Shift start not allowed due to schedule time of day and distance from home")
                    case .givenShiftAlreadyStarted:
                        self.handleShiftStartFailedDueToErrorWithForceStartOption(message: "givenShiftAlreadyStarted")
                    case .shiftWasStartedByDispatcher:
                        self.handleShiftStartFailedDueToErrorWithForceStartOption(message: "shiftWasStartedByDispatcher")
                    case .notAllMandatoryActionsAreFulfilled:
                        self.handleShiftStartFailedDueToErrorWithForceStartOption(message: "notAllMandatoryActionsAreFulfilled")
                    }
                case .startShiftCalledWithoutPendingShift:
                    self.handleShiftStartFailedDueToErrorWithForceStartOption(message: "Shift start without creating pending shift first")
                }
            }
        }
    }

    @objc private func endShiftButtonPressed(_ sender: UIButton) {
        // End shift is supported when offline.
        // Actions that are supported offline don't have completion blocks.
        // They change the local state of the app and update the server when network is available.
        // After calling endShift, you should treat the shift as ended.
        endShiftInitiatedFromClient = true
        _ = Bringg.shared.shiftManager.endShift()
        print("Ended shift")
        self.setViewTextAndEnabledDependingOnIsOnShiftState()
    }

    @objc private func showShiftHistoryButtonPressed(_ sender: UIButton) {
        let shiftHistoryViewController = ShiftHistoryViewController()
        navigationController?.pushViewController(shiftHistoryViewController, animated: true)
    }

    private func handleShiftStartFailedDueToErrorWithForceStartOption(message: String) {
        let alertController = UIAlertController(title: "Failed to start shift", message: message, preferredStyle: .actionSheet)
        let forceStartOption = UIAlertAction(title: "Force start", style: .default) { _ in
            self.forceStartShift()
            self.dismiss(animated: true, completion: nil)
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(forceStartOption)
        alertController.addAction(cancelOption)
        self.present(alertController, animated: true, completion: nil)
    }

    private func forceStartShift() {
        activityIndicatorView.startAnimating()
        Bringg.shared.shiftManager.forceStartShift { result in
            self.activityIndicatorView.stopAnimating()

            if case let .failure(error) = result {
                self.showError("Error starting shift. \(error)")
                return
            }

            print("Started shift")
            self.setViewTextAndEnabledDependingOnIsOnShiftState()
        }
    }

    // MARK: UserEventsDelegate

    func userDidLogin() {
        setViewVisabilityDependingOnLoginState()
    }

    func userDidLogout() {
        setViewVisabilityDependingOnLoginState()
    }

    // MARK: ShiftManagerDelegate

    func shiftStarted() {
        setViewTextAndEnabledDependingOnIsOnShiftState()
    }

    func shiftEnded() {
        setViewTextAndEnabledDependingOnIsOnShiftState()

        if endShiftInitiatedFromClient {
            endShiftInitiatedFromClient = false
            return
        }
        if view.window != nil {
            showMessage(title: "Shift ended", message: "Shift ended from the server")
        }
    }
}

class ShiftHistoryViewController: UITableViewController {
    private var shiftsHistory: [ShiftHistory]? {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadShifts()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlFired), for: .valueChanged)
        self.refreshControl = refreshControl

        tableView.register(ShiftHistoryTableViewCell.self, forCellReuseIdentifier: ShiftHistoryTableViewCell.cellIdentifier)
    }

    @objc private func refreshControlFired() {
        loadShifts(forceRefresh: true)
    }

    private func loadShifts(forceRefresh: Bool = false) {
        Bringg.shared.shiftHistoryManager.getShiftHistory(forceRefresh: forceRefresh) { result in
            switch result {
            case .success(let shiftsHistory):
                self.shiftsHistory = shiftsHistory
                self.refreshControl?.endRefreshing()
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        }
    }

    // MARK: UITableViewDelegate, UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftsHistory?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShiftHistoryTableViewCell.cellIdentifier, for: indexPath) as? ShiftHistoryTableViewCell else {
            return UITableViewCell()
        }

        let shift: ShiftHistory?
        if let shiftsHistory = shiftsHistory, indexPath.row < shiftsHistory.count {
            shift = shiftsHistory[indexPath.row]
        } else {
            shift = nil
        }
        
        cell.setShift(shift)
        return cell
    }
}

private class ShiftHistoryTableViewCell: UITableViewCell {
    static let cellIdentifier = "ShiftHistoryTableViewCellIdentifier"
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    // MARK: Views
    private lazy var shiftIdLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .gray
        return label
    }()

    private lazy var startTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private lazy var endTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(shiftIdLabel)
        contentView.addSubview(startTimeLabel)
        contentView.addSubview(endTimeLabel)

        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeConstraints() {
        shiftIdLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(6)
        }

        startTimeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(shiftIdLabel.snp.bottom).offset(6)
        }

        endTimeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(startTimeLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().offset(-6)
        }
    }

    func setShift(_ shift: ShiftHistory?) {
        if let shift = shift {
            shiftIdLabel.text = "Shift id: \(shift.id)"
            if let startDate = shift.startDate {
                startTimeLabel.text = "Start: \(ShiftHistoryTableViewCell.dateFormatter.string(from: startDate))"
            } else {
                startTimeLabel.text = "No start time for shift"
            }
            if let endDate = shift.endDate {
                endTimeLabel.text = "End: \(ShiftHistoryTableViewCell.dateFormatter.string(from: endDate))"
            } else {
                endTimeLabel.text = "No end time for shift"
            }
        } else {
            shiftIdLabel.text = nil
            startTimeLabel.text = nil
            endTimeLabel.text = nil
        }
    }
}
