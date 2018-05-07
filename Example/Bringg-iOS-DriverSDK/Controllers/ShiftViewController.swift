//
//  Copyright © 2018 Bringg. All rights reserved.
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

    private var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var endShiftInitiatedFromClient = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        Bringg.shared.loginManager.addDelegate(self)
        Bringg.shared.shiftManager.addDelegate(self)

        view.addSubview(currentShiftStateLabel)
        view.addSubview(startShiftButton)
        view.addSubview(endShiftButton)
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
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            } else {
                make.top.equalToSuperview().offset(15)
            }
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

        activityIndicatorView.snp.makeConstraints { make in
            make.top.equalTo(endShiftButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    private func isLoggedIn() -> Bool {
        return Bringg.shared.loginManager.currentUser != nil
    }

    private func isOnShift() -> Bool {
        return Bringg.shared.shiftManager.currentShift != nil
    }

    private func setViewVisabilityDependingOnLoginState() {
        if isLoggedIn() {
            notLoggedInView.isHidden = true
        } else {
            notLoggedInView.isHidden = false
        }
    }

    private func setViewTextAndEnabledDependingOnIsOnShiftState() {
        if isOnShift() {
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
        Bringg.shared.shiftManager.startShift { error, shiftStateError in
            self.activityIndicatorView.stopAnimating()

            if let error = error {
                self.showError("Error starting shift. \(error)")
                return
            }
            switch shiftStateError {
            case .none:
                print("Started shift")
                self.setViewTextAndEnabledDependingOnIsOnShiftState()
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
            }
        }
    }

    @objc private func endShiftButtonPressed(_ sender: UIButton) {
        //End shift is supported when offline.
        //Actions that are supported offline don't have completion blocks.
        //They change the local state of the app and update the server when network is available.
        //After calling endShift, you should treat the shift as ended.
        endShiftInitiatedFromClient = true
        Bringg.shared.shiftManager.endShift()
        print("Ended shift")
        self.setViewTextAndEnabledDependingOnIsOnShiftState()
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
        Bringg.shared.shiftManager.forceStartShift { error in
            self.activityIndicatorView.stopAnimating()

            if let error = error {
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
