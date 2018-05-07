//
//  Logger.swift
//
//  Created by Michael Tzach on 26/03/2018.
//  Copyright © 2018 Bringg. All rights reserved.
//

import Foundation
import BringgDriverSDK
import CocoaLumberjack

private class LogFormatter: NSObject, DDLogFormatter {
    static let shared = LogFormatter()
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss:SSS"
        return formatter
    }()
    
    func format(message logMessage: DDLogMessage) -> String? {
        let dateAndTime = dateFormatter.string(from: logMessage.timestamp)
        return "\(dateAndTime) - \(logMessage.message)"
    }
}

class Logger: LoggerProtocol {
    private static let logLevel: DDLogLevel = .info
    let ddLog = DDLog()
    
    init() {
        DDTTYLogger.sharedInstance.logFormatter = LogFormatter.shared
        ddLog.add(DDTTYLogger.sharedInstance, with: Logger.logLevel)
    }
    
    static private func format(_ message: String, file: String, function: String, line: UInt) -> String {
        return "\"\(file)\" \(function):\(line)\t\(message)"
    }
    
    func logDebug(_ message: String, file: String, function: String, line: UInt) {
        DDLogDebug(Logger.format(message, file: file, function: function, line: line), ddlog: ddLog)
    }
    
    func logInfo(_ message: String, file: String, function: String, line: UInt) {
        DDLogInfo(Logger.format(message, file: file, function: function, line: line), ddlog: ddLog)
    }
    
    func logWarn(_ message: String, file: String, function: String, line: UInt) {
        DDLogWarn(Logger.format(message, file: file, function: function, line: line), ddlog: ddLog)
    }
    
    func logError(_ message: String, file: String, function: String, line: UInt) {
        DDLogError(Logger.format(message, file: file, function: function, line: line), ddlog: ddLog)
    }
}
