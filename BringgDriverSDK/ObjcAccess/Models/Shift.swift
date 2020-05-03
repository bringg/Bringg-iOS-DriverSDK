//
//  Shift.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 21/11/2019.
//

import BringgDriverSDK
import Foundation

@objc public class Shift: NSObject {
    private let shift: BringgDriverSDK.Shift

    @objc public var id: NSNumber { NSNumber(value: shift.id) }
    @objc public var startDate: Date { shift.startDate }
    @objc public var endDate: Date? { shift.endDate }

    public convenience init?(shift: BringgDriverSDK.Shift?) {
        guard let shift = shift else { return nil }
        self.init(shift: shift)
    }

    public init(shift: BringgDriverSDK.Shift) {
        self.shift = shift
        super.init()
    }
}
