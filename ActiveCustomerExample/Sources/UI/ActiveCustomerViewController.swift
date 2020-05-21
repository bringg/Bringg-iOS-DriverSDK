//
//  ActiveCustomerViewController.swift
//  BringgActiveCustomerSDKExample
//
//

import BringgDriverSDK
import UIKit
import SnapKit

final class ActiveCustomerViewController: UIViewController {
    private lazy var activityIndicatorView = UIActivityIndicatorView()

    private lazy var controlsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                loginButton,
                logoutButton,

                startTaskButton,
                arriveAtWaypointButton,
                leaveWaypointButton,
                updatePickupETAButton,
            ]
        )

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()

    // MARK: - Auth related

    private lazy var loginButton = UIButton.createLargeStyleButton(
        title: "Login",
        target: self,
        selector: #selector(loginButtonPressed)
    )

    private lazy var logoutButton = UIButton.createLargeStyleButton(
        title: "Logout button",
        target: self,
        selector: #selector(logoutButtonPressed)
    )

    // MARK: - Task related

    private lazy var startTaskButton = UIButton.createLargeStyleButton(
        title: "Start task",
        target: self,
        selector: #selector(startTaskButtonPressed)
    )

    private lazy var arriveAtWaypointButton = UIButton.createLargeStyleButton(
        title: "Arrive at waypoint",
        target: self,
        selector: #selector(arriveAtWaypointButtonPressed)
    )

    private lazy var leaveWaypointButton = UIButton.createLargeStyleButton(
        title: "Leave waypoint",
        target: self,
        selector: #selector(leaveWaypointButtonPressed)
    )

    private lazy var updatePickupETAButton = UIButton.createLargeStyleButton(
        title: "Update ETA to pickup",
        target: self,
        selector: #selector(updatePickupETAButtonPressed)
    )

    private lazy var logTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Active customer"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        AppContext.activeCustomerManager.addDelegate(self)

        view.addSubview(activityIndicatorView)
        view.addSubview(controlsStackView)
        view.addSubview(logTextView)

        updateView()
    }

    private func updateView() {
        loginButton.isHidden = AppContext.activeCustomerManager.isLoggedIn
        logoutButton.isHidden = !AppContext.activeCustomerManager.isLoggedIn

        startTaskButton.isHidden = true
        arriveAtWaypointButton.isHidden = true
        leaveWaypointButton.isHidden = true
        updatePickupETAButton.isHidden = true

        if AppContext.activeCustomerManager.isLoggedIn {
            switch AppContext.activeCustomerManager.activeTask?.status {
            case .none:
                // No active task. Start task button should be enabled to allow activating a task if the user has a task
                startTaskButton.isHidden = false
            case .onTheWay:
                // The task is started and on the way to the waypoint.
                // Should allow customer reporting that he arrived or update the estimated time to arrival
                arriveAtWaypointButton.isHidden = false
                updatePickupETAButton.isHidden = false
            case .checkedIn:
                // The customer is already on location. Depending on the flow (who should finish the task - the customer or the store), we will display the leave button
                leaveWaypointButton.isHidden = false
            default:
                break
            }
        }

        remakeConstraints()
    }

    private func remakeConstraints() {
        activityIndicatorView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
        }

        controlsStackView.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
        }
        logTextView.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalTo(controlsStackView.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - Auth related button handlers

    @objc private func loginButtonPressed() {
        activityIndicatorView.startAnimating()
        addLog("Logging in...")
        HTTPService.shared.getUserToken { result in
            switch result {
            case .failure(let error):
                self.activityIndicatorView.stopAnimating()
                self.showError(error.localizedDescription)
                self.updateView()
                print("SDK Login finished with failure")
            case .success(let userToken):
                AppContext.activeCustomerManager.login(
                    withToken: userToken.accessToken,
                    secret: userToken.secret,
                    region: userToken.region
                ) { error in
                    self.activityIndicatorView.stopAnimating()
                    self.updateView()
                    if let sdkLoginError = error {
                        print("SDK Login finished with failure")
                        self.addLog("login failed \(String(describing: error))")
                        self.showError(sdkLoginError.localizedDescription)
                    } else {
                        self.addLog("login succeeded")
                        print("SDK Login finished with success")
                    }
                }
            }
        }
    }

    @objc private func logoutButtonPressed() {
        activityIndicatorView.startAnimating()

        print("Logging out")
        AppContext.activeCustomerManager.logout {
            print("Logout finished")
            self.activityIndicatorView.stopAnimating()
            self.updateView()
        }
    }

    // MARK: - Task related button handlers

    @objc private func startTaskButtonPressed() {
        addLog("Starting task")

        activityIndicatorView.startAnimating()

        HTTPService.shared.getActiveTask { result in
            switch result {
            case .failure(let error):
                self.addLog("Finished starting task with error")
                self.showError(error.localizedDescription)
                self.activityIndicatorView.stopAnimating()
            case .success(let getActiveTask):
                self.addLog("Starting task \(getActiveTask.taskId)")

                AppContext.activeCustomerManager.startTask(with: getActiveTask.taskId) { error in
                    self.activityIndicatorView.stopAnimating()
                    if let error = error {
                        self.addLog("Finished staring task with failure")
                        self.showError(error.localizedDescription)
                    } else {
                        self.addLog("Finished starting task with success")
                    }
                }
            }
        }
    }

    @objc private func arriveAtWaypointButtonPressed() {
        addLog("Arriving at waypoint")
        AppContext.activeCustomerManager.arriveAtWaypoint { error in
            self.activityIndicatorView.stopAnimating()
            if let error = error {
                self.showError(error.localizedDescription)
                self.addLog("Arriving at waypoint finished with an error")
                self.addLog("\(error)")
            } else {
                self.addLog("Arriving at waypoint finished with success")
            }
        }
    }

    @objc private func leaveWaypointButtonPressed() {
        addLog("Leaving waypoint")
        AppContext.activeCustomerManager.leaveWaypoint { error in
            self.activityIndicatorView.stopAnimating()
            if let error = error {
                print("Finished leaving waypoint with failure")
                self.showError(error.localizedDescription)
                self.addLog("\(error)")
            } else {
                print("Finished leaving waypoint with success")
                self.addLog("Leave waypoint finished")
            }
        }
    }

    @objc private func updatePickupETAButtonPressed() {
        addLog("Moving to date picker view")

        let dateTimePicker = DateTimePickerViewController { [weak self] updatedETA in
            guard let self = self else { return }
            self.addLog("New eta submitted. \(updatedETA)")
            self.navigationController?.popViewController(animated: true)

            AppContext.activeCustomerManager.updateWaypointETA(eta: updatedETA) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.addLog("Failed updating eta \(error)")
                } else {
                    self.addLog("Finished updating eta")
                }
            }
        }
        dateTimePicker.title = "Update ETA"
        navigationController?.pushViewController(dateTimePicker, animated: true)
    }

    private func addLog(_ text: String) {
        print(text)
        logTextView.text = "\(text)\n\(logTextView.text ?? "")"
    }
}

// MARK: - ActiveCustomerManagerDelegate

extension ActiveCustomerViewController: ActiveCustomerManagerDelegate {
    func activeCustomerManagerDidLogout() {
        updateView()
    }

    func activeCustomerManagerActiveTaskUpdated(_ sender: ActiveCustomerManagerProtocol) {
        // This delegate method will be called when the active task is updated
        // When starting a task, this will be called as activeTask changes from `nil` to the active task.
        // With every update to the task caused either from user interaction or a change on the server, this will be called.
        // When the active task is done, this will be called and `activeTask` will be nil

        print("activeTask updated \(String(describing: sender.activeTask))")
        updateView()
    }
}
