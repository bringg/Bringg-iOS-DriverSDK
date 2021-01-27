//
//  Debounce.swift
//  BringgDriverSDK
//
//  Created by Michael Tzach on 02/12/2018.
//

import Foundation

/*
 * After calling `debounce`, it will wait `timeInterval` and after that time it will fire the latest action that was passed to it.
 * When calling `debounce` the action will be called after a max time of `timeInterval`.
 *
 * |**************************timeInterval*******************************|
 * |firstEvent|*****|anotherEvent1|**|anotherEvent2|**|anotherEvent2Fired|
 */

public class Debounce {
    private var timeInterval: TimeInterval
    private var action: (() -> Void)?
    private var timer: Timer?

    public init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    public func invalidate() {
        // This is synchronized because it could be called from the outside simultaneously with the timerFired calling it. Highly unlikely but it did happen.
        // Error name: Simultaneous accesses to 0x600001305398, but modification requires exclusive access
        synchronized() {
            timer?.invalidate()
            timer = nil
            action = nil
        }
    }

    public func debounce(action: @escaping () -> Void) {
        self.action = action
        if self.timer == nil {
            let timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
            self.timer = timer
            if !Thread.isMainThread {
                RunLoop.current.add(timer, forMode: .default)
                RunLoop.current.run()
            }
        }
    }

    @objc private func timerFired() {
        action?()
        invalidate()
    }

    private func synchronized(_ block: () -> Void) {
        objc_sync_enter(self)
        block()
        objc_sync_exit(self)
    }
}


