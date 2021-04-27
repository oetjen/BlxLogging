//
//  BlxLoggingTests.swift
//  BlxLoggingTests
//
//  Created by Andreas Oetjen on 22.03.21.
//

import XCTest
@testable import BlxLogging

class BlxLoggingTests: XCTestCase {

    override func setUpWithError() throws {
        let l = BlxLogger.instance
        l.clean()
        l.output = .none
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testErrorLog() throws {
        let l = BlxLogger.instance
        l.output = .print
        l.logError("An error occurred"); let expectedLine = #line
        let all = l.entries.toArray()
        XCTAssertEqual(all.count, 1, "Expected exactly one entry in entries array")
        
        let entry = all[0]
        XCTAssertEqual(entry.level, BlxLogLevel.error, "Expected correct log level")
        XCTAssertEqual(entry.line, expectedLine, "Expected correct line number")
        XCTAssertEqual (entry.fileID, #fileID, "Expected correct file name")
        XCTAssertEqual (entry.function, #function, "Expected correct function name")
    }
    

    
    func testLogOverrun() throws {
        let maxSize = 10
        let skipCount = 90
        let callCount = skipCount + maxSize
        let l = BlxLogger.init(maxLogSize: maxSize)
        for i in 1..<callCount {
            l.logError("Test \(i)")
        }
        let all = l.entries.toArray()
        let expectedCount = 10
        XCTAssertEqual(all.count, expectedCount, "Expected exactly \(expectedCount) entries")
        for (inx, entry) in all.enumerated() {
            XCTAssertEqual (entry.message, "Test \(skipCount + inx)")
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        //self.measure {
            // Put the code you want to measure the time of here.
        //}
    }

}
