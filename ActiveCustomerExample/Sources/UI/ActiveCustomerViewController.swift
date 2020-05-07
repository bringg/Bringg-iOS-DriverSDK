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
                sendFeedbackButton,
                getTasksButton
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
    
    private lazy var sendFeedbackButton = UIButton.createLargeStyleButton(
        title: "Send Feedback",
        target: self,
        selector: #selector(sendFeedbackPressed)
    )
    
    private lazy var getTasksButton = UIButton.createLargeStyleButton(
        title: "Get Tasks",
        target: self,
        selector: #selector(getTasksPressed)
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

        startTaskButton.isHidden = !AppContext.activeCustomerManager.isLoggedIn
        arriveAtWaypointButton.isHidden = !AppContext.activeCustomerManager.isLoggedIn
        leaveWaypointButton.isHidden = !AppContext.activeCustomerManager.isLoggedIn
        sendFeedbackButton.isHidden = !AppContext.activeCustomerManager.isLoggedIn
        getTasksButton.isHidden = !AppContext.activeCustomerManager.isLoggedIn

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
        let context = "start task"
        addLog("Starting task")
        getActiveTask(context: context) { getActiveTask in
            self.addLog("Starting task \(getActiveTask.taskId) waypoint \(getActiveTask.waypointId)")
            AppContext.activeCustomerManager.startTask(with: getActiveTask.taskId) { error in
                self.activityIndicatorView.stopAnimating()
                if let error = error {
                    print("Finished \(context) with failure")
                    self.showError(error.localizedDescription)
                    self.addLog("start task failed")
                    self.addLog("\(error)")
                } else {
                    print("Finished \(context) with success")
                    self.addLog("Task started \(getActiveTask.taskId) waypoint \(getActiveTask.waypointId)")
                }
            }
        }
    }

    @objc private func arriveAtWaypointButtonPressed() {
        let context = "arrive at waypoint"
        addLog("Arrive task")
        getActiveTask(context: context) { getActiveTask in
            self.addLog("Arrive task \(getActiveTask.taskId) waypoint \(getActiveTask.waypointId)")
            AppContext.activeCustomerManager.arriveAtWaypoint(with: getActiveTask.waypointId) { error in
                self.activityIndicatorView.stopAnimating()
                if let error = error {
                    print("Finished \(context) with failure")
                    self.showError(error.localizedDescription)
                    self.addLog("Arrive task failed \(getActiveTask.taskId) waypoint \(getActiveTask.waypointId)")
                    self.addLog("\(error)")
                } else {
                    print("Finished \(context) with success")
                    self.addLog("Arrive task finished \(getActiveTask.taskId) waypoint \(getActiveTask.waypointId)")
                }
            }
        }
    }

    @objc private func leaveWaypointButtonPressed() {
        let context = "leave waypoint"
        getActiveTask(context: context) { getActiveTask in
            self.addLog("Leave task \(getActiveTask.taskId) waypoint \(getActiveTask.waypointId)")
            AppContext.activeCustomerManager.leaveWaypoint(with: getActiveTask.waypointId) { error in
                self.activityIndicatorView.stopAnimating()
                if let error = error {
                    print("Finished \(context) with failure")
                    self.showError(error.localizedDescription)
                    self.addLog("Leave task failed \(getActiveTask.taskId) waypoint \(getActiveTask.waypointId)")
                    self.addLog("\(error)")
                } else {
                    print("Finished \(context) with success")
                    self.addLog("Leave task finished \(getActiveTask.taskId) waypoint \(getActiveTask.waypointId)")
                }
            }
        }
    }
    
    @objc private func sendFeedbackPressed() {
        addLog("Sending logs")
        Bringg.shared.logReportManager.sendLogsToServer { error in
            self.addLog("Logs sent")
        }
    }
    
    @objc private func getTasksPressed() {
        Bringg.shared.tasksManager.getTasks { tasks, timestamp, error in
            self.addLog("Tasks")
            tasks?.forEach {
                self.addLog("id:\($0.id) status:\($0.status) checkin:\($0.waypoints[0].checkinTime) checkout: \($0.waypoints[0].checkoutTime)")
            }
        }
    }

    // Completion will be fired on success only
    private func getActiveTask(context: String, completion: @escaping (GetActiveTask) -> Void) {
        activityIndicatorView.startAnimating()
        print("Starting \(context)")
        HTTPService.shared.getActiveTask { result in
            switch result {
            case .failure(let error):
                print("Finished \(context) with failure")
                self.showError(error.localizedDescription)
                self.activityIndicatorView.stopAnimating()
            case .success(let getActiveTask):
                completion(getActiveTask)
            }
        }
    }
    
    private func addLog(_ text: String) {
        logTextView.text = "\(text)\n\(logTextView.text ?? "")"
        
    }
}

// MARK: - ActiveCustomerManagerDelegate

extension ActiveCustomerViewController: ActiveCustomerManagerDelegate {
    func activeCustomerManagerDidLogout() {
        updateView()
    }

    func activeCustomerManager(_ sender: ActiveCustomerManagerProtocol, taskRemovedWithId taskId: Int) {
        // In some customer flows, the client only reports on task start and arrive at waypoint (pickup location).
        // This delegate method will be called in those flows where the store reports the task checked out (customer left pickup location).
        // Consider adding a message to the customer that the task is done.
        showMessage(title: "Thank you", message: "You pickuped up your package from the store.")
    }
}
