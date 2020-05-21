//
//  UserManager.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 17/05/2020.
//

import BringgDriverSDK
import Foundation

@objc public protocol UserManagerProtocol {
    func setUserTransportType(_ transportType: TransportType, completion: ((Error?) -> Void)?)
}

@objc class UserManager: NSObject, UserManagerProtocol {
    private let userManager: BringgDriverSDK.UserManagerProtocol

    init(userManager: BringgDriverSDK.UserManagerProtocol) {
        self.userManager = userManager
    }

    func setUserTransportType(_ transportType: TransportType, completion: ((Error?) -> Void)?) {
        userManager.setUserTransportType(transportType, completion: completion)
    }
}
