//
//  Waypoint.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 18/05/2020.
//

import BringgDriverSDK
import Foundation

@objc public class Waypoint: NSObject {
    private let waypoint: BringgDriverSDK.Waypoint

    // Ids
    @objc public var id: Int { waypoint.id }
    @objc public var taskId: Int { waypoint.taskId }

    // Location
    @objc public var address: String? { waypoint.address }
    @objc public var addressSecondLine: String? { waypoint.addressSecondLine }
    @objc public var addressType: AddressType { waypoint.addressType ?? AddressType.none }
    @objc public var locationName: String? { waypoint.locationName }
    @objc public var lat: NSNumber? { NSNumber(value: waypoint.lat) }
    @objc public var lng: NSNumber? { NSNumber(value: waypoint.lng) }
    @objc public var zipcode: String? { waypoint.zipcode }
    @objc public var borough: String? { waypoint.borough }
    @objc public var city: String? { waypoint.city }
    @objc public var street: String? { waypoint.street }
    @objc public var state: String? { waypoint.state }
    @objc public var neighborhood: String? { waypoint.neighborhood }
    @objc public var district: String? { waypoint.district }
    @objc public var houseNumber: NSNumber? { NSNumber(value: waypoint.houseNumber) }

    // Times
    @objc public var checkinTime: Date? { waypoint.checkinTime }
    @objc public var checkoutTime: Date? { waypoint.checkoutTime }
    @objc public var scheduledAt: Date? { waypoint.scheduledAt }
    @objc public var hasToLeaveBy: Date? { waypoint.hasToLeaveBy }
    @objc public var etl: Date? { waypoint.etl }
    @objc public var eta: Date? { waypoint.eta }
    @objc public var noEarlierThan: Date? { waypoint.noEarlierThan }
    @objc public var noLaterThan: Date? { waypoint.noLaterThan }

    // State
    @objc public var position: NSNumber? { NSNumber(value: waypoint.position) }
    @objc public var done: Bool { waypoint.done ?? false }
    @objc public var late: Bool { waypoint.late ?? false }
    @objc public var asap: Bool { waypoint.asap ?? false }
    @objc public var rating: String? { waypoint.rating }

    // Behaviour
    @objc public var pickupDropoffOption: PickupDropoffOption { waypoint.pickupDropoffOption ?? PickupDropoffOption.none }

    @objc public var findMe: Bool { waypoint.findMe ?? false }
    
    @objc public var uiDataColor: String? { waypoint.uiData.color }
    @objc public var uiDataNumber: NSNumber? { NSNumber(value: waypoint.uiData.number) }

    // Contact
    @objc public var companyName: String? { waypoint.companyName }
    @objc public var name: String? { waypoint.name }
    @objc public var phoneAvailable: Bool { waypoint.phoneAvailable ?? false }

    // Relationships
    @objc public var customer: Customer? { Customer(customer: waypoint.customer) }
    @objc public var contacts: [Contact]? { waypoint.contacts?.map { Contact(contact: $0) } }
    @objc public var extraCustomers: [Customer]? { waypoint.extraCustomers?.map { Customer(customer: $0) } }
    @objc public var taskNotes: [TaskNote]? { waypoint.taskNotes?.map { TaskNote(taskNote: $0) } }
    @objc public var inventoryItems: [TaskInventory]? { waypoint.inventoryItems?.map { TaskInventory(taskInventory: $0) } }

    init(waypoint: BringgDriverSDK.Waypoint) {
        self.waypoint = waypoint
    }
}
