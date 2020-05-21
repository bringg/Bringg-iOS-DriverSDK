//
//  TaskNote.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 18/05/2020.
//

import BringgDriverSDK
import Foundation

@objc public enum TaskNoteType: Int {
    case notSupported = -1 // Some task note types are not supported in objc
    case note
}

@objc public class TaskNote: NSObject {
    private let taskNote: BringgDriverSDK.TaskNote

    @objc public var id: Int { taskNote.id }
    @objc public var taskInventoryId: NSNumber? { NSNumber(value: taskNote.taskInventoryId) }

    @objc public var type: TaskNoteType {
        switch taskNote.typeAndData {
        case .unknown, .form, .html, .formattedTaskNote, .signature, .photo: return .notSupported

        case .note: return .note
        }
    }

    @objc public var note: String? {
        switch taskNote.typeAndData {
        case .unknown, .signature, .photo, .form, .html, .formattedTaskNote: return nil

        case .note(let note): return note
        }
    }

    @objc public var createdAt: Date { taskNote.createdAt }
    @objc public var updatedAt: Date? { taskNote.updatedAt }

    init(taskNote: BringgDriverSDK.TaskNote) {
        self.taskNote = taskNote
    }
}
