//
//  ShiftManager.swift
//  BringgDriverSDKObjc
//
//  Created by Michael Tzach on 21/11/2019.
//

import BringgDriverSDK
import Foundation

@objc public protocol ShiftManagerDelegate: class {
    func shiftStarted()
    func shiftEnded()
}

@objc public protocol ShiftManagerProtocol {
    @objc var isOnShift: Bool { get }
    @objc var currentShift: Shift? { get }

    @discardableResult
    @objc func addDelegate(_ delegate: ShiftManagerDelegate) -> MulticastDelegateSubscription

    @objc func startShift(completion: @escaping (_ networkError: Error?, _ stateError: StartShiftErrorType) -> Void)
    @objc func forceStartShift(completion: @escaping (_ error: Error?) -> Void)
    @objc func endShift()
}

@objc public final class ShiftManager: NSObject, ShiftManagerProtocol {
    private let shiftManager: BringgDriverSDK.ShiftManagerProtocol
    
    private let delegates = MulticastDelegate<ShiftManagerDelegate>()
    
    init(shiftManager: BringgDriverSDK.ShiftManagerProtocol) {
        self.shiftManager = shiftManager
        
        super.init()
        
        shiftManager.addDelegate(self)
    }
    
    public var isOnShift: Bool { shiftManager.isOnShift }
    public var currentShift: Shift? { Shift(shift: shiftManager.currentShift) }

    @discardableResult
    public func addDelegate(_ delegate: ShiftManagerDelegate) -> MulticastDelegateSubscription {
        delegates.add(delegate)
    }

    public func startShift(completion: @escaping (Error?, StartShiftErrorType) -> Void) {
        shiftManager.startShift { result in
            switch result {
            case .failure(let error):
                switch error {
                case .notAllMandatoryActionsAreFulfilled:
                    completion(error, .notAllMandatoryActionsAreFulfilled)
                case .startShiftCalledWhileShiftOperationInProgress, .startShiftCalledWithoutPendingShift:
                    completion(error, .none)
                case .generalError(let error):
                    completion(error, .none)
                case .stateErrorFromTheServer(let stateError):
                    completion(nil, stateError)
                }
            case .success:
                completion(nil, .none)
            }
        }
    }
    
    public func forceStartShift(completion: @escaping (Error?) -> Void) {
        shiftManager.forceStartShift { result in
            switch result {
            case .failure(let error):
                switch error {
                case .notAllMandatoryActionsAreFulfilled, .startShiftAlreadyInProgress, .startShiftCalledWithoutPendingShift:
                    completion(error)
                case .generalError(let error):
                    completion(error)
                }
            case .success:
                completion(nil)
            }
        }
    }
    
    public func endShift() {
        _ = shiftManager.endShift()
    }
}

extension ShiftManager: BringgDriverSDK.ShiftManagerDelegate {
    public func shiftStarted() {
        delegates.invoke { $0.shiftStarted() }
    }
    
    public func shiftEnded() {
        delegates.invoke { $0.shiftEnded() }
    }
}
