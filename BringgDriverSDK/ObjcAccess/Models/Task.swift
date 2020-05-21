//
//  Task.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 18/05/2020.
//

import BringgDriverSDK
import Foundation

@objc public class Task: NSObject {
    private var task: BringgDriverSDK.Task

    // Ids
    @objc public var id: Int { task.id }
    @objc public var externalId: String? { task.externalId }
    @objc public var userId: NSNumber? { NSNumber(value: task.userId) }

    // State and details
    @objc public var status: TaskStatus { task.status }
    @objc public var title: String? { task.title }
    @objc public var priority: NSNumber? { NSNumber(value: task.priority) }
    @objc public var asap: Bool { task.asap ?? false }
    @objc public var startedTime: Date? { task.startedTime }
    @objc public var scheduledAt: Date? { task.scheduledAt }
    @objc public var activeWaypointId: NSNumber? { NSNumber(value: task.activeWaypointId) }

    // Configurations Ids
    @objc public var tagId: NSNumber? { NSNumber(value: task.tagId) }
    @objc public var taskTypeId: TaskType { task.taskTypeId ?? .none }

    // Group task
    @objc public var groupUUID: String? { task.groupUUID }

    // Payment
    @objc public var totalPrice: NSNumber? { NSNumber(value: task.totalPrice) }
    @objc public var deliveryPrice: NSNumber? { NSNumber(value: task.deliveryPrice) }
    @objc public var leftToBePaid: NSNumber? { NSNumber(value: task.leftToBePaid) }

    // Relationships
    @objc public var waypoints: [Waypoint] { task.waypoints.map { Waypoint(waypoint: $0) } }
    @objc public var taskInventories: [TaskInventory]? { task.taskInventories?.map { TaskInventory(taskInventory: $0) } }

    @objc public func getJSONDict() -> [String: AnyHashable]? { task.jsonDict }

    init?(task: BringgDriverSDK.Task?) {
        guard let task = task else { return nil }
        self.task = task
    }
}
