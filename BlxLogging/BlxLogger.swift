//
//  BlxLogger.swift
//  BlxLogger
//
//  Created by Andreas Oetjen on 19.03.21.
//

import Foundation
import OSLog

public enum BlxLogLevel : Int, Codable, Comparable {
    public static func < (lhs: BlxLogLevel, rhs: BlxLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case off        = -1
    case debug      = 0
    case warning    = 1
    case error      = 2
}

public struct BlxLogOutput : OptionSet {
    public let rawValue: Int
    
    public init(rawValue:Int) {
        self.rawValue = rawValue
    }
    
    public static let none         = BlxLogOutput(rawValue:1 << 0)
    public static let print        = BlxLogOutput(rawValue:1 << 1)
    public static let textFile     = BlxLogOutput(rawValue:1 << 2)
    public static let jsonFile     = BlxLogOutput(rawValue:1 << 3)
}

public class BlxLogger {
    public static var logLevel = BlxLogLevel.error
    public var output:BlxLogOutput = [.none]

    var entries:BlxRollingList<BlxLogEntry>
    private let logFileName:String
    private lazy var queue:DispatchQueue = {
        let q = DispatchQueue.init(label: "BlxLogger", qos: .background)
        return q
    }()
    
    lazy var logFileUrl:URL = {
        let tmpDir = FileManager.default.temporaryDirectory
        let url = tmpDir.appendingPathComponent(logFileName)
        return url
    }()
    
    public static let instance = BlxLogger()
    
    
    public init(maxLogSize:Int = 1000, logFileName:String = "blxLog.log") {
        self.entries = BlxRollingList(capacity:maxLogSize)
        self.logFileName = logFileName
    }
    
    public func clean() {
        entries.clean()
        try? FileManager.default.removeItem(at: self.logFileUrl)
    }
    
    public func logDebug (_ text:String, error:Error? = nil, file:String = #fileID, line: Int = #line, function:String = #function) {
        log(text, level:.debug, error: error, file:file, line:line, function:function)
    }

    public func logWarning (_ text:String, error:Error? = nil, file:String = #fileID, line: Int = #line, function:String = #function) {
        log(text, level:.error, error: error, file:file, line:line, function:function)
    }

    public func logError (_ text:@autoclosure ()->String, error:Error? = nil, file:String = #fileID, line: Int = #line, function:String = #function) {
        log(text(), level:.error, error: error, file:file, line:line, function:function)
    }
    
    @discardableResult
    public func log (_ text:@autoclosure ()->String, level:BlxLogLevel = .error, error:Error? = nil, file:String = #fileID, line: Int = #line, function:String = #function) -> BlxLogEntry? {
        guard (level >= BlxLogger.logLevel) else { return nil }
        
        let entry = BlxLogEntry(level: level, message:text(), fileID: file, line: line, function: function, error:error)

        entries.add(entry)
        printEntry(entry)
        return entry
    }
    
    @discardableResult
    public func flushFile() -> TimeInterval {
        let start = Date()
        self.queue.sync {
            if output.contains(.jsonFile) {
                writeToLogFile("]")
            }
            // Do nothing -- will just wait until all other enqueued
            // Tasks have been completed
        }
        let end = Date()
        let duration = end.timeIntervalSince(start)
        return duration
    }
    
    private func printEntry(_ entry:BlxLogEntry) {
        if (output.contains(.print)) {
            print (entry.string())
        }
        
        if (!output.isDisjoint(with: [.textFile, .jsonFile])) {
            self.queue.async { [self] in
                let message = output.contains(.textFile)
                                ? entry.string()
                                : entry.jsonString() + ","
                writeToLogFile(message)
            }
        }
        
        /*
        var msg = text
        if let error = error {
            msg = "\(text): \(String(describing:error))"
        }
        let filename = URL(fileURLWithPath: file).lastPathComponent
        let dateText = Date().timestampString

        let message =  "ERROR # \(dateText) # \(filename) (\(line)) # \(function) # [:\(threadId)] \(msg)"
        
        print (message)
        traceFile(message)
        Global.errorMessages.add(element: message)
        */
    }
    
    private func writeToLogFile(_ message:String) {
        var message = message + "\n"
        do {
            if FileManager.default.fileExists(atPath: self.logFileUrl.path) {
                let fileHandle = try FileHandle(forWritingTo: self.logFileUrl)
                try fileHandle.seekToEnd()
                guard let messageData = message.data(using: .utf8) else { return }
                fileHandle.write(messageData)
                fileHandle.closeFile()
            } else {
                if (output.contains(.jsonFile)) {
                    message = "[\n" + message
                }
                guard let messageData = message.data(using: .utf8) else { return }
                try messageData.write(to: self.logFileUrl, options: .atomicWrite)
            }
        } catch let e {
            // If logging fails, better not try to log this failure also.
            // So we give up and just print it
            print(e)
            print(message)
        }

    }
    
    
    
}
