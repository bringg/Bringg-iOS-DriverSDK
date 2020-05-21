//
//  TaskInventory.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 18/05/2020.
//

import BringgDriverSDK
import Foundation

@objc public class TaskInventory: NSObject {
    private let taskInventory: BringgDriverSDK.TaskInventory

    // Ids
    @objc public var id: Int { taskInventory.id }
    @objc public var inventoryId: NSNumber? { NSNumber(value: taskInventory.inventoryId) }
    @objc public var waypointId: NSNumber? { NSNumber(value: taskInventory.waypointId) }
    @objc public var externalId: String? { taskInventory.externalId }

    // Quantities and pricing
    @objc public var price: NSNumber? { NSNumber(value: taskInventory.price) }
    @objc public var originalQuantity: NSNumber? { NSNumber(value: taskInventory.originalQuantity) }
    @objc public var quantity: NSNumber? { NSNumber(value: taskInventory.quantity) }
    @objc public var rejectedQuantity: NSNumber? { NSNumber(value: taskInventory.rejectedQuantity) }

    // Inventory info
    @objc public var name: String? { taskInventory.name }
    @objc public var note: String? { taskInventory.note }
    @objc public var scanString: String? { taskInventory.scanString }
    @objc public var pending: Bool { taskInventory.pending ?? false }

    @objc public var image: URL? { taskInventory.image?.url }

    // Dimensions
    @objc public var height: NSNumber? { NSNumber(value: taskInventory.dimensions?.height) }
    @objc public var width: NSNumber? { NSNumber(value: taskInventory.dimensions?.width) }
    @objc public var length: NSNumber? { NSNumber(value: taskInventory.dimensions?.length) }

    // Relationships
    @objc public var subInventories: [TaskInventory]? { taskInventory.subInventories?.map { TaskInventory(taskInventory: $0) } }

    init(taskInventory: BringgDriverSDK.TaskInventory) {
        self.taskInventory = taskInventory
    }
}
