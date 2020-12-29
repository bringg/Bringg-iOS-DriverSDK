//
//  CustomerVehicle.swift
//  BringgDriverSDKObjc
//
//  Created by Ido Mizrachi on 23/12/2020.
//

import BringgDriverSDK
import Foundation

@objc public class CustomerVehicle: NSObject {
    let customerVehicle: BringgDriverSDK.CustomerVehicle
    
    @objc public var id: NSNumber? {
        if let customerVehicleId = customerVehicle.id {
            return NSNumber(value: customerVehicleId)
        } else {
            return nil
        }
    }
    @objc public var saveVehicle: Bool { customerVehicle.saveVehicle }
    @objc public var licensePlate: String? { customerVehicle.licensePlate }
    @objc public var color: String? { customerVehicle.color }
    @objc public var model: String? { customerVehicle.model }
    @objc public var parkingSpot: String? { customerVehicle.parkingSpot }
    
    init(customerVehicle: BringgDriverSDK.CustomerVehicle) {
        self.customerVehicle = customerVehicle
    }
    
    @objc public init(
        id: Int,
        saveVehicle: Bool,
        licensePlate: String?,
        color: String?,
        model: String?,
        parkingSpot: String?
    ) {
        self.customerVehicle = BringgDriverSDK.CustomerVehicle(
            id: id,
            saveVehicle: saveVehicle,
            licensePlate: licensePlate,
            color: color,
            model: model,
            parkingSpot: parkingSpot
        )
    }
    
    @objc public init(
        saveVehicle: Bool,
        licensePlate: String?,
        color: String?,
        model: String?,
        parkingSpot: String?
    ) {
        self.customerVehicle = BringgDriverSDK.CustomerVehicle(
            id: nil,
            saveVehicle: saveVehicle,
            licensePlate: licensePlate,
            color: color,
            model: model,
            parkingSpot: parkingSpot
        )
    }
}
