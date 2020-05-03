//
//  Logger.swift
//
//  Created by Michael Tzach on 26/03/2018.
//  Copyright © 2018 Bringg. All rights reserved.
//

import BringgDriverSDK
import CocoaLumberjack
import Foundation

private class LogFormatter: NSObject, DDLogFormatter {
    static let shared = LogFormatter()

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss:SSS"
        return formatter
    }()

    func format(message logMessage: DDLogMessage) -> String? {
        let dateAndTime = dateFormatter.string(from: logMessage.timestamp)
        return "\(dateAndTime) - \(logMessage.message)"
    }
}

class Logger: LoggerProtocol {
    private static let logLevel: DDLogLevel = .debug
    let ddLog = DDLog()

    init() {
        DDTTYLogger.sharedInstance.logFormatter = LogFormatter.shared
        ddLog.add(DDTTYLogger.sharedInstance, with: Logger.logLevel)
    }

    static private func format(_ message: String, file: String, function: String, line: UInt) -> String {
        var formattedMessage = ""
        if !file.isEmpty {
            formattedMessage.append("\"\(file)\" ")
        }
        if !function.isEmpty {
            formattedMessage.append("\(function)")
        }
        if line > 0 {
            formattedMessage.append(":\(line)")
        }
        formattedMessage.append(" ")
        formattedMessage.append(message)
        return formattedMessage
    }

    func logDebug(_ message: String, file: String, function: String, line: UInt) {
        DDLogDebug("[DEBUG] " + Logger.format(message, file: file, function: function, line: line), ddlog: ddLog)
    }

    func logInfo(_ message: String, file: String, function: String, line: UInt) {
        DDLogInfo(Logger.format(message, file: file, function: function, line: line), ddlog: ddLog)
    }

    func logWarn(_ message: String, file: String, function: String, line: UInt) {
        DDLogWarn("[WARN] ⚠️ " + Logger.format(message, file: file, function: function, line: line), ddlog: ddLog)
    }

    func logError(_ message: String, file: String, function: String, line: UInt) {
        DDLogError("[ERROR] 🆘 " + Logger.format(message, file: file, function: function, line: line), ddlog: ddLog)
    }
}
