//
//  OpenIdConfiguration.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 11/02/2020.
//

import BringgDriverSDK
import Foundation

@objc final public class OpenIdConfiguration: NSObject {
    let openIdConfiguration: BringgDriverSDK.OpenIdConfiguration

    @objc public var issuer: URL { openIdConfiguration.issuer }
    @objc public var clientId: String { openIdConfiguration.clientId }

    init(openIdConfiguration: BringgDriverSDK.OpenIdConfiguration) {
        self.openIdConfiguration = openIdConfiguration
    }
}
