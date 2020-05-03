//
//  User.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 16/12/2019.
//

import BringgDriverSDK
import Foundation

@objc public final class User: NSObject {
    private let user: BringgDriverSDK.User

    @objc public var id: NSNumber { NSNumber(value: user.id) }
    @objc public var atHome: NSNumber? {
        guard let atHome = user.atHome else { return nil }
        return NSNumber(value: atHome)
    }
    @objc public var name: String? { user.name }
    @objc public var profileImage: String? { user.profileImage?.urlString }
    @objc public var defaultUserActivity: DriverActivityType { user.defaultUserActivity ?? .driving }
    @objc public var debug: Bool { user.debug ?? false }
    @objc public var uuid: String? { user.uuid }
    @objc public var email: String? { user.email }
    @objc public var phone: String? { user.phone }
    @objc public var merchantId: NSNumber? {
        guard let merchantId = user.merchantId else { return nil }
        return NSNumber(value: merchantId)
    }

    init?(user: BringgDriverSDK.User?) {
        guard let user = user else { return nil }
        self.user = user
        super.init()
    }
}
