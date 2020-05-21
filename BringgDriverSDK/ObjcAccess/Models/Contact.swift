//
//  Contact.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 18/05/2020.
//

import BringgDriverSDK
import Foundation

@objc public class Contact: NSObject {
    private let contact: BringgDriverSDK.Contact

    @objc public var customerId: NSNumber? { NSNumber(value: contact.customerId) }
    @objc public var contactType: ContactType { contact.contactType }

    @objc public var contactValue: String? { contact.contactValue }
    @objc public var sharingAllowed: Bool { contact.sharingAllowed ?? false }

    init(contact: BringgDriverSDK.Contact) {
        self.contact = contact
    }
}
