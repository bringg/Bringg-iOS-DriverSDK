//
//  NSNumber+Utils.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 18/05/2020.
//

import Foundation

extension NSNumber {
    convenience init?(value: Int?) {
        guard let value = value else { return nil }
        self.init(value: value)
    }

    convenience init?(value: Double?) {
        guard let value = value else { return nil }
        self.init(value: value)
    }
}
