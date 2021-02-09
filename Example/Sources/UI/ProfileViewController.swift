//
//  ProfileViewController.swift
//  BringgDriverSDKExample
//
//  Copyright © 2020 Bringg. All rights reserved.
//

import AVFoundation
import BringgDriverSDKObjc
import PhoneNumberKit
import SnapKit
import UIKit

class ProfileViewController: UIViewController, UserEventsDelegate {
    private var loginViewController = LoginViewController()
    private var logoutViewController = LogoutViewController()
    private var currentViewController: UIViewController {
        if Bringg.shared.loginManager.currentUser != nil {
            return logoutViewController
        } else {
            return loginViewController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        Bringg.shared.loginManager.addDelegate(self)
        setChildViewControllerDependingOnLoginState()
    }

    private func remakeConstraints() {
        for viewController in [loginViewController, logoutViewController] as [UIViewController] {
            if viewController.view.superview != nil {
                viewController.view.snp.remakeConstraints({ make in
                    make.top.equalTo(view.safeAreaLayoutGuide)
                    make.bottom.equalTo(view.safeAreaLayoutGuide)
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                })
            }
        }
    }

    private func setChildViewControllerDependingOnLoginState() {
        for viewController in [loginViewController, logoutViewController] as [UIViewController] {
            if viewController.view.superview != nil {
                viewController.willMove(toParent: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
        }

        addChild(currentViewController)
        view.addSubview(currentViewController.view)
        currentViewController.didMove(toParent: self)

        remakeConstraints()
    }

    // MARK: UserEventsDelegate

    func userDidLogin() {
        setChildViewControllerDependingOnLoginState()
    }

    func userDidLogout() {
        setChildViewControllerDependingOnLoginState()
    }
}

private class LogoutViewController: UIViewController {
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

    private lazy var logoutButton = createButton(
        title: "Logout",
        selector: #selector(logoutButtonPressed)
    )

    private lazy var sendLogsToDispatcherButton = createButton(
        title: "Send Logs To Dispatcher",
        selector: #selector(sendLogsToDispatcherPressed)
    )

    private lazy var shareLogsButton = createButton(
        title: "Share Logs",
        selector: #selector(shareLogs)
    )

    private var activityIndicator = UIActivityIndicatorView(style: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(logoutButton)
        view.addSubview(sendLogsToDispatcherButton)
        view.addSubview(shareLogsButton)
        view.addSubview(activityIndicator)

        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin).offset(16)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.height.equalTo(48)
        }
        sendLogsToDispatcherButton.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.height.equalTo(48)
        }
        shareLogsButton.snp.makeConstraints { make in
            make.top.equalTo(sendLogsToDispatcherButton.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.height.equalTo(48)
        }
        activityIndicator.snp.makeConstraints { make in
            make.bottom.equalTo(logoutButton.snp.top)
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
        }
    }

    @objc private func logoutButtonPressed() {
        logoutButton.isEnabled = false
        activityIndicator.startAnimating()

        Bringg.shared.loginManager.logout {
            self.logoutButton.isEnabled = true
            self.activityIndicator.stopAnimating()

            print("logged out!")
        }
    }

    @objc private func sendLogsToDispatcherPressed() {
        Bringg.shared.logReportManager.sendLogsToServer()
        showMessage(title: "Sending logs to server", message: "🗒")
    }

    @objc private func shareLogs() {
        Bringg.shared.logReportManager.getStoredLogs { data in
            guard let data = data else { return }
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath = documentsPath + "/logs.txt"
            var bigData = Data()
            data.forEach {
                bigData.append($0)
            }
            let filePathUrl = URL(fileURLWithPath: filePath)
            try! bigData.write(to: filePathUrl)
            let activityViewController = UIActivityViewController(activityItems: [filePathUrl], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

private class LoginViewController: UIViewController {
    private enum Segments: Int, CaseIterable {
        case emailPassword
        case qrCode
        case phone

        var segmentName: String {
            switch self {
            case .emailPassword: return "email"
            case .qrCode: return "QR"
            case .phone: return "Phone"
            }
        }

        static var segmentNames: [String] { allCases.map { $0.segmentName } }
    }

    private lazy var loginTypeSelectView: UISegmentedControl = {
        let view = UISegmentedControl(items: Segments.segmentNames)
        view.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.selectedSegmentIndex = Segments.emailPassword.rawValue
        return view
    }()

    private lazy var emailPasswordLoginViewController = LoginEmailPasswordViewController()
    private lazy var QRLoginViewController = LoginQRViewController()
    private lazy var phoneLoginViewController = LoginPhoneViewController()

    private var allChildViewControllers: [UIViewController] {
        [emailPasswordLoginViewController, QRLoginViewController, phoneLoginViewController]
    }

    private var currentLoginViewController: UIViewController {
        switch Segments(rawValue: loginTypeSelectView.selectedSegmentIndex) ?? .emailPassword {
        case .phone:
            return phoneLoginViewController
        case .emailPassword:
            return emailPasswordLoginViewController
        case .qrCode:
            return QRLoginViewController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(loginTypeSelectView)
        loginTypeSelectView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        setLoginViewControllerDependingOnSegment()
    }

    private func remakeConstraints() {
        for viewController in allChildViewControllers {
            if viewController.view.superview != nil {
                viewController.view.snp.remakeConstraints { make in
                    make.top.equalTo(loginTypeSelectView.snp.bottom).offset(8)
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.bottom.equalToSuperview()
                }
            }
        }
    }

    private func setLoginViewControllerDependingOnSegment() {
        for viewController in allChildViewControllers {
            if viewController.view.superview != nil {
                viewController.willMove(toParent: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParent()
            }
        }

        addChild(currentLoginViewController)
        view.addSubview(currentLoginViewController.view)
        currentLoginViewController.didMove(toParent: self)

        remakeConstraints()
    }

    // MARK: UISegmentedControl target

    @objc private func segmentChanged() {
        setLoginViewControllerDependingOnSegment()
    }
}

private class LoginEmailPasswordViewController: UIViewController, UITextFieldDelegate {
    private lazy var emailTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "email"
        view.autocapitalizationType = .none
        view.autocorrectionType = .no
        view.keyboardType = .emailAddress
        view.delegate = self
        return view
    }()

    private lazy var passwordTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "password"
        view.isSecureTextEntry = true
        view.delegate = self
        return view
    }()

    private lazy var merchantIdTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "merchant id (optional)"
        view.keyboardType = .decimalPad
        view.delegate = self
        return view
    }()

    private lazy var submitButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        view.setTitle("login", for: .normal)
        view.setTitleColor(.black, for: .normal)
        return view
    }()

    private var activityIndicator = UIActivityIndicatorView(style: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(merchantIdTextField)
        view.addSubview(submitButton)
        view.addSubview(activityIndicator)

        makeConstraints()
    }

    private func makeConstraints() {
        emailTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        merchantIdTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(merchantIdTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.lessThanOrEqualToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func submitButtonPressed() {
        guard let email = emailTextField.text, !email.isEmpty else { showError("you must enter an email"); return }
        guard let password = passwordTextField.text, !password.isEmpty else { showError("you must enter a password"); return }

        activityIndicator.startAnimating()
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
        merchantIdTextField.isEnabled = false
        submitButton.isEnabled = false

        Bringg.shared.loginManager.login(withEmail: email, password: password, merchant: nil) { response in
            self.activityIndicator.stopAnimating()
            self.emailTextField.isEnabled = true
            self.passwordTextField.isEnabled = true
            self.merchantIdTextField.isEnabled = true
            self.submitButton.isEnabled = true

            switch response {
            case .failure(let errorType):
                switch errorType {
                case .unauthorized(let error): self.showError("Unauthorized: \(error.localizedDescription)")
                case .userIsNotADriver: self.showError("User is not a driver. only a driver can login to the driver app")
                case .other(let error): self.showError("There was an error: \(error.localizedDescription)")
                }
            case .success(let successType):
                switch successType {
                case .loggedIn:
                    print("logged in!")
                case .multipleMerchantsExistForUser(let merchants):
                    self.showMerchantList(merchants, merchantChosen: { merchantId in
                        self.merchantIdTextField.text = "\(merchantId)"
                        self.submitButtonPressed()
                    })
                case .shouldChangeToOpenIdConnect:
                    print("sso login is not supported in example app")
                }
            }

        }
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            merchantIdTextField.becomeFirstResponder()
        }
        if textField == merchantIdTextField {
            submitButtonPressed()
        }
        return false
    }
}

private class LoginQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private lazy var captureView = UIView()
    private var activityIndicator = UIActivityIndicatorView(style: .gray)

    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(captureView)
        view.addSubview(activityIndicator)
        captureView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
            make.width.equalTo(captureView.snp.height)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startRunningScan()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let qrCodeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let qrCode = qrCodeObject.stringValue else { return }

        stopRunningScan()
        activityIndicator.startAnimating()

        Bringg.shared.loginManager.login(withQRCode: qrCode) { error in
            self.activityIndicator.stopAnimating()

            if let error = error {
                self.showError("Invalid code. \(error)")
                self.startRunningScan()
                return
            }

            print("logged in!")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopRunningScan()
    }

    private func stopRunningScan() {
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer?.removeFromSuperlayer()
        videoPreviewLayer = nil
        captureView.isHidden = true
    }

    private func startRunningScan() {
        captureView.isHidden = false

        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { showError("No device for qr"); return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { showError("Was unable to init video captire"); return }
        let session = AVCaptureSession()
        captureSession = session
        session.addInput(input)

        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

        captureSession?.addOutput(captureMetadataOutput)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer = previewLayer
        captureView.layer.addSublayer(previewLayer)
        previewLayer.frame = captureView.bounds

        session.startRunning()

        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    }
}

private class LoginPhoneViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private struct Consts {
        static let initialCountryCode = "il"
        static let initialCountryCallingNumberCode = "+972"
    }

    private var countryCode: String = Consts.initialCountryCode

    private lazy var countryCodeNumberLabel: UILabel = {
        let view = UILabel()
        view.text = Consts.initialCountryCallingNumberCode
        view.textAlignment = .right
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(countryCodeLabelPressed))
        view.addGestureRecognizer(gestureRecognizer)
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var phoneNumberTextField: UITextField = {
        let view = UITextField()
        view.keyboardType = .decimalPad
        view.placeholder = "Phone number"
        return view
    }()

    private lazy var submitButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        view.setTitle("login", for: .normal)
        view.setTitleColor(.black, for: .normal)
        return view
    }()

    private lazy var countryCodePickerView: UIPickerView = {
        let view = UIPickerView()
        view.delegate = self
        view.dataSource = self
        return view
    }()

    private var activityIndicator = UIActivityIndicatorView(style: .gray)

    private var countryNameCodes = PhoneNumberKit().allCountries()
    private var countryChooserIsOpen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(countryCodeNumberLabel)
        view.addSubview(countryCodePickerView)
        view.addSubview(phoneNumberTextField)
        view.addSubview(submitButton)
        view.addSubview(activityIndicator)

        makeConstraints()
    }

    private func makeConstraints() {
        countryCodeNumberLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.width.equalToSuperview().dividedBy(5)
            make.height.equalTo(phoneNumberTextField)
        }

        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalTo(countryCodeNumberLabel.snp.right).offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(countryCodeNumberLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(submitButton.snp.bottom).offset(8)
        }

        remakeConstraintsForClosedCountryCodePicker()
    }

    private func remakeConstraintsForClosedCountryCodePicker() {
        countryCodePickerView.snp.remakeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.snp.bottom)
        }
    }

    private func remakeConstraintsForOpenCountryCodePicker() {
        countryCodePickerView.snp.remakeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview().offset(8)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
            make.centerX.equalToSuperview()
            make.top.equalTo(submitButton.snp.bottom).offset(15)
        }
    }

    @objc private func countryCodeLabelPressed() {
        UIView.animate(withDuration: 0.3) {
            if self.countryChooserIsOpen {
                self.remakeConstraintsForClosedCountryCodePicker()
            } else {
                self.remakeConstraintsForOpenCountryCodePicker()
            }
            self.countryChooserIsOpen = !self.countryChooserIsOpen

            self.view.layoutIfNeeded()
        }
    }

    @objc private func submitButtonPressed() {
        guard let countryCodeNumber = countryCodeNumberLabel.text, !countryCodeNumber.isEmpty else { showError("Must enter country code"); return }
        guard let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else { showError("Must enter phone number"); return }

        if countryChooserIsOpen {
            self.remakeConstraintsForOpenCountryCodePicker()
            self.view.layoutIfNeeded()
            countryChooserIsOpen = false
        }

        activityIndicator.startAnimating()
        Bringg.shared.loginManager.requestVerificationCode(forCountryCode: countryCode, phone: countryCodeNumber + phoneNumber) { error in
            self.activityIndicator.stopAnimating()

            if let error = error {
                self.showError("Couldn't send verification code. \(error)")
                return
            }

            let loginVerificationVC = LoginVerificationCodeViewController(countryCode: self.countryCode, phoneNumber: countryCodeNumber + phoneNumber)
            self.navigationController?.pushViewController(loginVerificationVC, animated: true)
        }
    }

    // MARK: UIPickerViewDelegate, UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryNameCodes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryNameCodes[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let countryNameCode = countryNameCodes[row]
        guard let countryCallingCode = PhoneNumberKit().countryCode(for: countryNameCode) else { return }

        self.countryCodeNumberLabel.text = "+\(countryCallingCode)"
        self.countryCode = countryNameCode
    }
}

private class LoginVerificationCodeViewController: UIViewController {

    private var countryCode: String
    private var phoneNumber: String

    init(countryCode: String, phoneNumber: String) {
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private lazy var verificationCodeTextField: UITextField = {
        let view = UITextField()
        view.keyboardType = .decimalPad
        view.placeholder = "Verification code"
        return view
    }()

    private lazy var merchantIdTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "merchant id"
        view.keyboardType = .decimalPad
        view.isEnabled = false
        return view
    }()

    private lazy var submitButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        view.setTitle("login", for: .normal)
        view.setTitleColor(.black, for: .normal)
        return view
    }()

    private var activityIndicator = UIActivityIndicatorView(style: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(verificationCodeTextField)
        view.addSubview(merchantIdTextField)
        view.addSubview(submitButton)
        view.addSubview(activityIndicator)

        makeConstraints()
    }

    private func makeConstraints() {
        verificationCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-8)
        }

        merchantIdTextField.snp.makeConstraints { make in
            make.top.equalTo(verificationCodeTextField.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(merchantIdTextField.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    @objc private func submitButtonPressed() {
        guard let verificationCode = verificationCodeTextField.text, verificationCode.count > 3 else { showError("Verification code must be at least three digits"); return }

        activityIndicator.startAnimating()
        Bringg.shared.loginManager.login(withVerificationCode: verificationCode, countryCode: countryCode, phone: phoneNumber, merchant: nil) { result in
            self.activityIndicator.stopAnimating()

            switch result {
            case .failure(let error):
                self.showError("there was an error: \(error)")
            case .success(.multipleMerchantsExistForUser(let merchants)):
                self.showMerchantList(merchants) { merchantId in
                    self.merchantIdTextField.text = "\(merchantId)"
                    self.submitButtonPressed()
                }
            case .success(.loggedIn):
                self.navigationController?.popViewController(animated: true)
                print("logged in!")
            case .success(.shouldChangeToOpenIdConnect):
                print("sso login is not supported in example app")
            }
        }
    }
}
