//
//  BlxLogEntry.swift
//  BlxLogging
//
//  Created by Andreas Oetjen on 22.03.21.
//

import Foundation

public struct BlxLogEntry : CustomDebugStringConvertible, Encodable {
    public var level:BlxLogLevel
    public var message:String
    public var fileID:String
    public var line:Int
    public var function:String
    public var threadId:mach_port_t = pthread_mach_thread_np(pthread_self())
    public var timestamp = Date()
    public var error:Error?
    
    public var debugDescription: String {
        let dateText = self.timestamp.timestampString
        let location =  "\(fileID) (\(line)) # \(level) # \(function)"
        
        var result = "\(dateText) # \(threadId) # \(location) # \(message)"
        if (error != nil) {
            result.append(" # \(String(describing:error))")
        }
        return result
    }
    
    private enum CodingKeys : String, CodingKey {
        case level
        case message
        case fileID
        case line
        case function
        case threadId
        case timestamp
        case error
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(level, forKey: .level)
        try container.encode(message, forKey: .message)
        try container.encode(fileID, forKey: .fileID)
        try container.encode(line, forKey: .line)
        try container.encode(function, forKey: .function)
        try container.encode(threadId, forKey: .threadId)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(error?.localizedDescription, forKey: .error)
    }

    public func string() -> String  {
        return "\(self)"
    }

    public func jsonString() -> String  {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try encoder.encode(self)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return self.string() }
            return jsonString
        } catch let e  {
            print (e)
            return self.string()
        }
    }
    
}



