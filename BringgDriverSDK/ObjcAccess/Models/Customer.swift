//
//  Customer.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 18/05/2020.
//

import BringgDriverSDK
import Foundation

@objc public class Customer: NSObject {
    private let customer: BringgDriverSDK.Customer

    // Ids
    @objc public var id: Int { customer.id }

    // Location
    @objc public var address: String? { customer.address }
    @objc public var addressSecondLine: String? { customer.addressSecondLine }
    @objc public var lat: NSNumber? { NSNumber(value: customer.lat) }
    @objc public var lng: NSNumber? { NSNumber(value: customer.lng) }

    // Customer data
    @objc public var image: String? { customer.image }
    @objc public var email: String? { customer.email }
    @objc public var phone: String? { customer.phone }
    @objc public var name: String? { customer.name }
    @objc public var allowSendingSMS: Bool { customer.allowSendingSMS ?? false }

    init?(customer: BringgDriverSDK.Customer?) {
        guard let customer = customer else { return nil }
        self.customer = customer
    }

    init(customer: BringgDriverSDK.Customer) {
        self.customer = customer
    }
}
