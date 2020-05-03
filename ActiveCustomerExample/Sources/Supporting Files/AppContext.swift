//
//  AppContext.swift
//  BringgActiveCustomerSDKExample
//
//

import BringgDriverSDK
import Foundation

class AppContext {
    static let activeCustomerManager: ActiveCustomerManagerProtocol = {
        let bringgInitializationError = Bringg.initializeSDK(logger: Logger())
        
        if let initError = bringgInitializationError {
            fatalError("Bringg SDK failed to initialize. error: \(initError.localizedDescription)")
        }
        
        return Bringg.shared.activeCustomerManager
    }()
}
