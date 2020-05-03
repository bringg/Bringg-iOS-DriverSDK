//
//  MerchantSelection.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 06/01/2020.
//

import BringgDriverSDK
import Foundation

@objc final public class MerchantSelection: NSObject {
    let merchantSelection: BringgDriverSDK.MerchantSelection

    @objc public var id: Int { merchantSelection.id }
    @objc public var name: String { merchantSelection.name }

    init(merchantSelection: BringgDriverSDK.MerchantSelection) {
        self.merchantSelection = merchantSelection
    }
}
