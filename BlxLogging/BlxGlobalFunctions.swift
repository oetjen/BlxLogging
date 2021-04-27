//
//  BlxGlobalFunctions.swift
//  BlxLogging
//
//  Created by Andreas Oetjen on 23.03.21.
//

import Foundation

#if DEBUG
public func pEnter(file:String = #fileID, line: Int = #line, function:String = #function) -> BlxFunctionCallEntry {
    return BlxFunctionCallTracker.instance.enter(file: file, line: line, function: function)
}

public func pLeave(_ entry:BlxFunctionCallEntry, line: Int = #line) {
    _ = BlxFunctionCallTracker.instance.leave(file: entry.filename, line: line, function: entry.function, callNumber: entry.callNumber)
}

public func logError(_ text:@autoclosure ()->String, error:Error? = nil, file:String = #fileID, line: Int = #line, function:String = #function) {
    BlxLogger.instance.logError(text(), error:error, file:file, line:line, function: function)
}

#else
@inlinable @inline(__always) public func pEnter() -> Any { return () }
@inlinable @inline(__always) public func pLeave(_ dummy:Any) { }
@inlinable @inline(__always) public func logError() {}
#endif

