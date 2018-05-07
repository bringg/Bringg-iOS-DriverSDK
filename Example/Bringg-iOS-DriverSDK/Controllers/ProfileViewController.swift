//
//  Copyright © 2018 Bringg. All rights reserved.
//

import AVFoundation
import BringgDriverSDK
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
                    if #available(iOS 11.0, *) {
                        make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                        make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                    } else {
                        make.top.equalToSuperview()
                        make.bottom.equalToSuperview()
                    }
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                })
            }
        }
    }

    private func setChildViewControllerDependingOnLoginState() {
        for viewController in [loginViewController, logoutViewController] as [UIViewController] {
            if viewController.view.superview != nil {
                viewController.willMove(toParentViewController: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
            }
        }

        addChildViewController(currentViewController)
        view.addSubview(currentViewController.view)
        currentViewController.didMove(toParentViewController: self)

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

    private lazy var logoutButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        view.setTitle("logout", for: .normal)
        view.setTitleColor(.black, for: .normal)
        return view
    }()

    private lazy var sendLogsToDispatcherButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(sendLogsToDispatcherPressed), for: .touchUpInside)
        view.setTitle("Send logs to dispatcher", for: .normal)
        view.setTitleColor(.black, for: .normal)
        return view
    }()

    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(logoutButton)
        view.addSubview(sendLogsToDispatcherButton)
        view.addSubview(activityIndicator)

        logoutButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        sendLogsToDispatcherButton.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(15)
            make.trailing.lessThanOrEqualToSuperview().offset(-15)
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

        Bringg.shared.loginManager.logout { error in
            self.logoutButton.isEnabled = true
            self.activityIndicator.stopAnimating()

            if let error = error {
                self.showError("error in logout: \(error)")
                return
            }

            print("logged out!")
        }
    }

    @objc private func sendLogsToDispatcherPressed() {
        sendLogsToDispatcherButton.isEnabled = false
        activityIndicator.startAnimating()

        Bringg.shared.logReportManager.sendLogsToServer { error in
            self.activityIndicator.stopAnimating()

            if let error = error {
                self.showError("error in sending logs to server: \(error)")
                return
            }

            self.showMessage(title: "Sent logs to server", message: "Great success")
        }
    }
}

private class LoginViewController: UIViewController {
    private enum Segments: Int {
        case emailPassword
        case qrCode
        case phone

        static func segmentNames() -> [String] {
            return ["eMail", "QR", "Phone"]
        }
    }

    private lazy var loginTypeSelectView: UISegmentedControl = {
        let view = UISegmentedControl(items: Segments.segmentNames())
        view.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.selectedSegmentIndex = 0
        return view
    }()

    private lazy var emailPasswordLoginViewController = LoginEmailPasswordViewController()
    private lazy var QRLoginViewController = LoginQRViewController()
    private lazy var phoneLoginViewController = LoginPhoneViewController()

    private var allChildViewControllers: [UIViewController] {
        return [emailPasswordLoginViewController, QRLoginViewController, phoneLoginViewController]
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
                viewController.willMove(toParentViewController: nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
            }
        }

        addChildViewController(currentLoginViewController)
        view.addSubview(currentLoginViewController.view)
        currentLoginViewController.didMove(toParentViewController: self)

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

    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

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

        var merchantId: NSNumber?
        if let merchantIdString = merchantIdTextField.text, let merchantIdInt = Int(merchantIdString) {
            merchantId = NSNumber(value: merchantIdInt)
        }

        activityIndicator.startAnimating()
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
        merchantIdTextField.isEnabled = false
        submitButton.isEnabled = false

        Bringg.shared.loginManager.login(withEmail: email, password: password, merchantID: merchantId) { merchantList, error in
            self.activityIndicator.stopAnimating()
            self.emailTextField.isEnabled = true
            self.passwordTextField.isEnabled = true
            self.merchantIdTextField.isEnabled = true
            self.submitButton.isEnabled = true

            if let error = error {
                self.showError("there was an error: \(error)")
                return
            }
            if let merchantList = merchantList {
                self.showMerchantList(merchantList, merchantChosen: { merchantId in
                    self.merchantIdTextField.text = "\(merchantId)"
                    self.submitButtonPressed()
                })
                return
            }

            print("logged in!")
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
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

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
    private lazy var countryCodeLabel: UILabel = {
        let view = UILabel()
        view.text = "+972"
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

    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    private var countryNameCodes = PhoneNumberKit().allCountries()
    private var countryChooserIsOpen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(countryCodeLabel)
        view.addSubview(countryCodePickerView)
        view.addSubview(phoneNumberTextField)
        view.addSubview(submitButton)
        view.addSubview(activityIndicator)

        makeConstraints()
    }

    private func makeConstraints() {
        countryCodeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.width.equalToSuperview().dividedBy(5)
            make.height.equalTo(phoneNumberTextField)
        }

        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalTo(countryCodeLabel.snp.right).offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(countryCodeLabel.snp.bottom)
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
        guard let countryCode = countryCodeLabel.text, !countryCode.isEmpty else { showError("Must enter country code"); return }
        guard let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else { showError("Must enter phone number"); return }

        if countryChooserIsOpen {
            self.remakeConstraintsForOpenCountryCodePicker()
            self.view.layoutIfNeeded()
            countryChooserIsOpen = false
        }

        activityIndicator.startAnimating()
        Bringg.shared.loginManager.requestVerificationCode(forPhone: countryCode + phoneNumber) { error in
            self.activityIndicator.stopAnimating()

            if let error = error {
                self.showError("Couldn't send verification code. \(error)")
                return
            }

            let phoneNumberWithCountryCode = countryCode + phoneNumber
            self.navigationController?.pushViewController(LoginVerificationCodeViewController(phoneNumber: phoneNumberWithCountryCode), animated: true)
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
        guard let countryCode = PhoneNumberKit().countryCode(for: countryNameCode) else { return }
        countryCodeLabel.text = "+\(countryCode)"
    }
}

private class LoginVerificationCodeViewController: UIViewController {

    private var phoneNumber: String

    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private lazy var verificationCodeTextField: UITextField = {
        let view = UITextField()
        view.keyboardType = .decimalPad
        view.placeholder = "Verification code"
        return view
    }()

    private lazy var merchantIdTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "merchant id (optional)"
        view.keyboardType = .decimalPad
        return view
    }()

    private lazy var submitButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        view.setTitle("login", for: .normal)
        view.setTitleColor(.black, for: .normal)
        return view
    }()

    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

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
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview()
            }
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

        var merchantId: NSNumber?
        if let merchantIdString = merchantIdTextField.text, let merchantIdInt = Int(merchantIdString) {
            merchantId = NSNumber(value: merchantIdInt)
        }

        activityIndicator.startAnimating()
        Bringg.shared.loginManager.login(withVerificationCode: verificationCode, phone: phoneNumber, merchantID: merchantId) { merchantList, error in
            self.activityIndicator.stopAnimating()

            if let error = error {
                self.showError("there was an error: \(error)")
                return
            }
            if let merchantList = merchantList {
                self.showMerchantList(merchantList, merchantChosen: { merchantId in
                    self.merchantIdTextField.text = "\(merchantId)"
                    self.submitButtonPressed()
                })
                return
            }

            self.navigationController?.popViewController(animated: true)
            print("logged in!")
        }
    }
}
