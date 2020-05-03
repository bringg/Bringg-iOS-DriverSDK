//
//  BringgObjc.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 09/12/2018.
//

import BringgDriverSDK

@objc public class BringgObjc: NSObject {
    // swiftlint:disable:next implicitly_unwrapped_optional
    @objc public static var shared: BringgObjc!

    @objc public let loginManager: LoginManagerProtocol
    @objc public let shiftManager: ShiftManagerProtocol

    private init(bringgDriverSDK: BringgDriverSDK.Bringg) throws {
        self.loginManager = LoginManager(loginManager: bringgDriverSDK.loginManager)
        self.shiftManager = ShiftManager(shiftManager: bringgDriverSDK.shiftManager)
        super.init()
    }
}

extension BringgObjc {
    @objc public static func initializeSDK(logger: LoggerProtocol? = nil) -> Error? {
        do {
            if Bringg.shared == nil {
                let driverSDKInitError = Bringg.initializeSDK(logger: logger)
                if let error = driverSDKInitError {
                    throw error
                }
            }
            print("Initializing obj sdk wrapper")
            BringgObjc.shared = try BringgObjc(bringgDriverSDK: Bringg.shared)
            print("Initialize obj sdk finished")
            return nil
        } catch {
            print("Error on Bringg SDK Objc initialization: \(error.localizedDescription)")
            return error
        }
    }
}
