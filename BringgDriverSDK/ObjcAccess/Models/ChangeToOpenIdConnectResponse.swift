//
//  ChangeToOpenIdConnectResponse.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 11/02/2020.
//

import BringgDriverSDK
import Foundation

@objc public class ChangeToOpenIdConnectResponse: NSObject {
    @objc public let merchantSelection: MerchantSelection
    @objc public let openIdConfiguration: OpenIdConfiguration

    init(merchantSelection: BringgDriverSDK.MerchantSelection, openIdConfiguration: BringgDriverSDK.OpenIdConfiguration) {
        self.merchantSelection = MerchantSelection(merchantSelection: merchantSelection)
        self.openIdConfiguration = OpenIdConfiguration(openIdConfiguration: openIdConfiguration)

        super.init()
    }
}
