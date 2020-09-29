//
//  ShiftHistory.swift
//  BringgDriverSDKObjc
//
//  Created by Ido Mizrachi on 06/09/2020.
//

import BringgDriverSDK
import Foundation

@objc public class ShiftHistory: NSObject {
    private let shiftHistory: BringgDriverSDK.ShiftHistory

    @objc public var id: NSNumber { NSNumber(value: shiftHistory.id) }
    @objc public var startDate: Date? { shiftHistory.startDate }
    @objc public var endDate: Date? { shiftHistory.endDate }

    public convenience init?(shift: BringgDriverSDK.ShiftHistory?) {
        guard let shift = shift else { return nil }
        self.init(shift: shift)
    }

    public init(shiftHistory: BringgDriverSDK.ShiftHistory) {
        self.shiftHistory = shiftHistory
        super.init()
    }
}
