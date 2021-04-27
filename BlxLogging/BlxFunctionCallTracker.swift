//
//  BlxFunctionCallTracker.swift
//  BlxLogging
//
//  Created by Andreas Oetjen on 22.03.21.
//

import Foundation




/**
 Note: This class does not work multi-threaded!
 */
public class BlxFunctionCallTracker {
    
    public static var instance = BlxFunctionCallTracker()
    public static var maxEntries = 2000
    public var output:BlxLogOutput = [.none]
    
    var rollingHistory:BlxRollingList<BlxFunctionCallEntry>
    var callCount = 0
    private var currentCallDepth = 0

    public var history:[BlxFunctionCallEntry] {
        return rollingHistory.toArray()
    }

    private init() {
        self.rollingHistory = BlxRollingList<BlxFunctionCallEntry>(capacity: Self.maxEntries)
    }
    
    public func clean() {
        let capacity = self.rollingHistory.capacity
        self.rollingHistory = BlxRollingList<BlxFunctionCallEntry>(capacity: capacity)
        callCount = 0
        currentCallDepth = 0
    }
    
    func enter(file:String, line:Int, function:String) -> BlxFunctionCallEntry {
        currentCallDepth += 1
        callCount += 1
        let filename = URL(fileURLWithPath: file).lastPathComponent
        
        let entry = BlxFunctionCallEntry(level:currentCallDepth, isEntry:true, filename:filename, line: line, function: function, callNumber: callCount)
        
        rollingHistory.add(entry)
        
        if (self.output.contains(.print)) {
            print(entry.debugDescription)
        }
        return entry
    }
    
    func leave(file:String, line:Int, function:String, callNumber:Int) -> BlxFunctionCallEntry {
        let filename = URL(fileURLWithPath: file).lastPathComponent
        
        let entry = BlxFunctionCallEntry(level:currentCallDepth, isEntry:false, filename:filename, line: line, function: function, callNumber: callNumber)
        rollingHistory.add(entry)
        currentCallDepth -= 1

        if (self.output.contains(.print)) {
            print(entry.debugDescription)
        }

        return entry
    }

    public func historyInRange(_ range:Range<Int>) -> ArraySlice<BlxFunctionCallEntry> {
        return rollingHistory.toArray()[range]
    }
    
    public func lastHistoryEntries(count:Int) -> ArraySlice<BlxFunctionCallEntry> {
        let array = rollingHistory.toArray()
        let start = max(array.count - count, 0)
        
        return array[start...]
    }
    
    public func currentCallHistory() -> ArraySlice<BlxFunctionCallEntry> {
        var size = 0
        let historyArray = rollingHistory.toArray()
        for entry in historyArray.reversed() {
            size += 1
            if (entry.level == 1 && entry.isEnter) {
                return lastHistoryEntries(count: size)
            }
        }
        return ArraySlice(rollingHistory.toArray())
    }
}
