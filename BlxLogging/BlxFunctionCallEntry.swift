//
//  BlxFunctionCallEntry.swift
//  BlxLogging
//
//  Created by Andreas Oetjen on 22.03.21.
//

import Foundation

public struct BlxFunctionCallEntry : CustomDebugStringConvertible {
    public var level:Int
    public var isEnter:Bool
    public var isLeave:Bool { return !isEnter }
    public var filename:String
    public var line:Int
    public var function:String
    public var timestamp:Date
    public var callNumber:Int
    
    public var debugDescription: String {
        let dateText = self.timestamp.timestampString
        let indentation = Array(repeating: "  ", count: level).joined()
        let entryString = isEnter ? "-->" : "<--"
        let levelString = String(format:"L:%02d", level)
        let location =  "\(filename) (\(line)) # \(levelString) \(indentation) \(entryString) \(function)"
        
        let result = "\(dateText) # \(location) #\(callNumber)"
        return result
    }
    
    var shortDescription: String {
        let indentation = Array(repeating: "  ", count: level).joined()
        let entryString = isEnter ? "-->" : "<--"
        let levelString = String(format:"L:%02d", level)
        let location =  "\(levelString) \(indentation) \(entryString) \(function)"
        
        let result = "\(location) #\(callNumber)"
        return result
    }
    
    init(level:Int, isEntry:Bool, filename:String, line:Int, function:String, callNumber:Int = -1) {
        self.level = level
        self.isEnter = isEntry
        self.filename = filename
        self.line = line
        self.function = function
        self.callNumber = callNumber
        self.timestamp = Date()
    }
}

extension BlxFunctionCallEntry : Equatable {
    public static func==(lhs:BlxFunctionCallEntry, rhs:BlxFunctionCallEntry) -> Bool {
        return lhs.line == rhs.line &&
            lhs.function == rhs.function &&
            lhs.filename == rhs.filename
    }
}
