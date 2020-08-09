//
//  ActiveCustomerManager.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 17/05/2020.
//

import BringgDriverSDK
import Foundation

@objc public protocol ActiveCustomerManagerProtocol {
    @discardableResult
    func addDelegate(_ delegate: ActiveCustomerManagerDelegate) -> MulticastDelegateSubscription

    // MARK: - Login related

    var isLoggedIn: Bool { get }
    func login(
        withToken token: String,
        secret: String,
        region: String,
        completion: @escaping (Error?) -> Void
    )
    func logout(completion: @escaping () -> Void)

    // MARK: - Task related

    func startTask(with taskId: Int, completion: @escaping (Error?) -> Void)
    func arriveAtWaypoint(completion: @escaping (Error?) -> Void)
    func leaveWaypoint(completion: @escaping (Error?) -> Void)
    func updateWaypointETA(eta: Date, completion: @escaping (Error?) -> Void)

    var activeTask: Task? { get }

    func setUserTransportType(_ transportType: TransportType, completion: ((Error?) -> Void)?)
}

@objc public protocol ActiveCustomerManagerDelegate: AnyObject {
    func activeCustomerManagerActiveTaskUpdated(_ sender: ActiveCustomerManagerProtocol)
    func activeCustomerManagerDidLogout()
}

@objc class ActiveCustomerManager: NSObject, ActiveCustomerManagerProtocol {
    private let activeCustomerManager: BringgDriverSDK.ActiveCustomerManagerProtocol
    private let delegates: MulticastDelegate<ActiveCustomerManagerDelegate>

    var activeTask: Task? { Task(task: activeCustomerManager.activeTask) }

    init(activeCustomerManager: BringgDriverSDK.ActiveCustomerManagerProtocol) {
        self.activeCustomerManager = activeCustomerManager
        self.delegates = MulticastDelegate<ActiveCustomerManagerDelegate>()

        super.init()

        activeCustomerManager.addDelegate(self)
    }

    @discardableResult
    func addDelegate(_ delegate: ActiveCustomerManagerDelegate) -> MulticastDelegateSubscription {
        delegates.add(delegate)
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

    func arriveAtWaypoint(completion: @escaping (Error?) -> Void) {
        activeCustomerManager.arriveAtWaypoint(completion: completion)
    }

    func leaveWaypoint(completion: @escaping (Error?) -> Void) {
        activeCustomerManager.leaveWaypoint(completion: completion)
    }

    func setUserTransportType(_ transportType: TransportType, completion: ((Error?) -> Void)?) {
        activeCustomerManager.setUserTransportType(transportType, completion: completion)
    }

    func updateWaypointETA(eta: Date, completion: @escaping (Error?) -> Void) {
        activeCustomerManager.updateWaypointETA(eta: eta, completion: completion)
    }
}

// MARK: - ActiveCustomerManagerDelegate

extension ActiveCustomerManager: BringgDriverSDK.ActiveCustomerManagerDelegate {
    func activeCustomerManagerActiveTaskUpdated(_ sender: BringgDriverSDK.ActiveCustomerManagerProtocol) {
        delegates.invoke { $0.activeCustomerManagerActiveTaskUpdated(self) }
    }

    func activeCustomerManagerDidLogout() {
        delegates.invoke { $0.activeCustomerManagerDidLogout() }
    }
}
