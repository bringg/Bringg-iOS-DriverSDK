//
//  ActiveCustomerManager.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 17/05/2020.
//

import BringgDriverSDK
import Foundation

@objc public protocol ActiveCustomerManagerProtocol {
    func addDelegate(_ delegate: ActiveCustomerManagerDelegate)
    func removeDelegate(_ delegate: ActiveCustomerManagerDelegate)

    var isLoggedIn: Bool { get }
    func login(
        withToken token: String,
        secret: String,
        region: String,
        completion: @escaping (Error?) -> Void
    )
    func logout(completion: @escaping () -> Void)

    func startTask(with taskId: Int, completion: @escaping (Error?) -> Void)
    func arriveAtWaypoint(with waypointId: Int, completion: @escaping (Error?) -> Void)
    func leaveWaypoint(with waypointId: Int, completion: @escaping (Error?) -> Void)
}

@objc public protocol ActiveCustomerManagerDelegate: AnyObject {
    func activeCustomerManager(_ sender: ActiveCustomerManagerProtocol, taskRemovedWithId taskId: Int)
    func activeCustomerManagerDidLogout()
}

@objc class ActiveCustomerManager: NSObject, ActiveCustomerManagerProtocol {
    private let activeCustomerManager: BringgDriverSDK.ActiveCustomerManagerProtocol
    private let delegates: MulticastDelegate<ActiveCustomerManagerDelegate>

    init(activeCustomerManager: BringgDriverSDK.ActiveCustomerManagerProtocol) {
        self.activeCustomerManager = activeCustomerManager
        self.delegates = MulticastDelegate<ActiveCustomerManagerDelegate>()

        super.init()

        activeCustomerManager.addDelegate(self)
    }

    func addDelegate(_ delegate: ActiveCustomerManagerDelegate) {
        delegates.add(delegate)
    }
    func removeDelegate(_ delegate: ActiveCustomerManagerDelegate) {
        delegates.remove(delegate)
    }

    var isLoggedIn: Bool { activeCustomerManager.isLoggedIn }

    func login(
        withToken token: String,
        secret: String,
        region: String,
        completion: @escaping (Error?) -> Void
    ) {
        activeCustomerManager.login(withToken: token, secret: secret, region: region, completion: completion)
    }

    func logout(completion: @escaping () -> Void) {
        activeCustomerManager.logout(completion: completion)
    }

    func startTask(with taskId: Int, completion: @escaping (Error?) -> Void) {
        activeCustomerManager.startTask(with: taskId, completion: completion)
    }

    func arriveAtWaypoint(with waypointId: Int, completion: @escaping (Error?) -> Void) {
        activeCustomerManager.arriveAtWaypoint(with: waypointId, completion: completion)
    }

    func leaveWaypoint(with waypointId: Int, completion: @escaping (Error?) -> Void) {
        activeCustomerManager.leaveWaypoint(with: waypointId, completion: completion)
    }
}

// MARK: - ActiveCustomerManagerDelegate

extension ActiveCustomerManager: BringgDriverSDK.ActiveCustomerManagerDelegate {
    func activeCustomerManager(_ sender: BringgDriverSDK.ActiveCustomerManagerProtocol, taskRemovedWithId taskId: Int) {
        delegates.invoke { $0.activeCustomerManager(self, taskRemovedWithId: taskId) }
    }

    func activeCustomerManagerDidLogout() {
        delegates.invoke { $0.activeCustomerManagerDidLogout() }
    }
}
