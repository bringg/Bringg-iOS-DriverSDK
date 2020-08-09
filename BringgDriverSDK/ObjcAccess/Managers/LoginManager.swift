//
//  LoginManager.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 09/12/2018.
//

import BringgDriverSDK

@objc public class LoginWithEmailAndPasswordErrorCodes: NSObject {
    @objc public static let userIsNotADriver = 1500
    @objc public static let unauthorized = 1501
}

@objc public protocol LoginManagerProtocol {
    @objc var currentUser: User? { get }
    @objc var isLoggedIn: Bool { get }

    @discardableResult
    @objc func addDelegate(_ delegate: UserEventsDelegate) -> MulticastDelegateSubscription

    @objc func login(
        withEmail email: String,
        password: String,
        merchant: MerchantSelection?,
        completion: @escaping ([MerchantSelection]?, ChangeToOpenIdConnectResponse?, Error?) -> Void
    )
    @objc func requestVerificationCode(forCountryCode: String, phone: String, completion: @escaping (Error?) -> Void)
    @objc func login(
        withVerificationCode code: String,
        countryCode: String,
        phone: String,
        merchant: MerchantSelection?,
        completion: @escaping ([MerchantSelection]?, ChangeToOpenIdConnectResponse?, Error?) -> Void
    )
    @objc func login(withQRCode code: String, completion: @escaping (Error?) -> Void)
    @objc func logout(completion: @escaping () -> Void)
    @objc func recoverPassword(forEmail email: String, completion: @escaping (Error?) -> Void)
}

@objc public class LoginManager: NSObject, LoginManagerProtocol {
    private let loginManager: BringgDriverSDK.LoginManagerProtocol

    public var currentUser: User? { User(user: loginManager.currentUser) }

    public var isLoggedIn: Bool { loginManager.isLoggedIn }

    init(loginManager: BringgDriverSDK.LoginManagerProtocol) {
        self.loginManager = loginManager
    }

    @discardableResult
    public func addDelegate(_ delegate: UserEventsDelegate) -> MulticastDelegateSubscription {
        loginManager.addDelegate(delegate)
    }

    public func login(
        withEmail email: String,
        password: String,
        merchant: MerchantSelection?,
        completion: @escaping ([MerchantSelection]?, ChangeToOpenIdConnectResponse?, Error?) -> Void
    ) {
        loginManager.login(withEmail: email, password: password, merchant: merchant?.merchantSelection) { response in
            switch response {
            case .success(let loginSuccessType):
                switch loginSuccessType {
                case .loggedIn:
                    completion(nil, nil, nil)
                case .shouldChangeToOpenIdConnect(let merchant, let openIdConnectConfiguration):
                    let changeToOpenIdConnectResponse = ChangeToOpenIdConnectResponse(
                        merchantSelection: merchant,
                        openIdConfiguration: openIdConnectConfiguration
                    )
                    completion(nil, changeToOpenIdConnectResponse, nil)
                case .multipleMerchantsExistForUser(let merchants):
                    let merchantsResponse = merchants.map { MerchantSelection(merchantSelection: $0) }
                    completion(merchantsResponse, nil, nil)
                }
            case .failure(let loginErrorType):
                switch loginErrorType {
                case .other(let error):
                    completion(nil, nil, error)
                case .unauthorized(let error as NSError):
                    let error = NSError(domain: "LoginManager", code: LoginWithEmailAndPasswordErrorCodes.unauthorized, userInfo: error.userInfo)
                    completion(nil, nil, error)
                case .userIsNotADriver:
                    let error = NSError(domain: "LoginManager", code: LoginWithEmailAndPasswordErrorCodes.userIsNotADriver, userInfo: nil)
                    completion(nil, nil, error)
                }
            }
        }
    }

    @objc public func requestVerificationCode(forCountryCode: String, phone: String, completion: @escaping (Error?) -> Void) {
        loginManager.requestVerificationCode(forCountryCode: forCountryCode, phone: phone, completion: completion)
    }

    @objc public func login(
        withVerificationCode code: String,
        countryCode: String,
        phone: String,
        merchant: MerchantSelection?,
        completion: @escaping ([MerchantSelection]?, ChangeToOpenIdConnectResponse?, Error?) -> Void
    ) {
        loginManager.login(withVerificationCode: code, countryCode: countryCode, phone: phone, merchant: merchant?.merchantSelection) { result in
            switch result {
            case .success(let loginSuccessType):
                switch loginSuccessType {
                case .loggedIn:
                    completion(nil, nil, nil)
                case .multipleMerchantsExistForUser(let merchants):
                    let merchantsResponse = merchants.map { MerchantSelection(merchantSelection: $0) }
                    completion(merchantsResponse, nil, nil)
                case .shouldChangeToOpenIdConnect(let merchant, let openIdConnectConfiguration):
                    let changeToOpenIdConnectResponse = ChangeToOpenIdConnectResponse(
                        merchantSelection: merchant,
                        openIdConfiguration: openIdConnectConfiguration
                    )
                    completion(nil, changeToOpenIdConnectResponse, nil)
                }
            case .failure(let error):
                completion(nil, nil, error)
            }
        }
    }

    @objc public func login(withQRCode code: String, completion: @escaping (Error?) -> Void) {
        loginManager.login(withQRCode: code, completion: completion)
    }

    @objc public func logout(completion: @escaping () -> Void) {
        loginManager.logout(completion: completion)
    }

    @objc public func recoverPassword(forEmail email: String, completion: @escaping (Error?) -> Void) {
        loginManager.recoverPassword(forEmail: email, completion: completion)
    }
}
