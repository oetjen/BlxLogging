//
//  BxLoggingHierarchyTests.swift
//  BlxLoggingTests
//
//  Created by Andreas Oetjen on 22.03.21.
//

import XCTest
@testable import BlxLogging

class BxLoggingHierarchyTests: XCTestCase {

    override func setUpWithError() throws {
        let l = BlxLogger.instance
        l.clean()
        l.output = .none
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogLevelHierarchyAllLevels() throws {
        let l = BlxLogger.instance
        BlxLogger.logLevel = .debug
        l.log("A debug message", level: .debug)
        l.log("A warning message", level: .warning)
        l.log("An error message", level: .error)
    
        let all = l.entries.toArray()
        let expectedCount = 3
        XCTAssertEqual(all.count, expectedCount, "Expected exactly \(expectedCount) entries")
    }
    
    func testLogLevelHierarchyError() throws {
        let l = BlxLogger.instance
        BlxLogger.logLevel = .error
        l.log("A debug message", level: .debug)
        l.log("A warning message", level: .warning)
        l.log("An error message", level: .error)
    
        let all = l.entries.toArray()
        let expectedCount = 1
        XCTAssertEqual(all.count, expectedCount, "Expected exactly \(expectedCount) entries")
        let entry = all[0]
        XCTAssertEqual(entry.level, BlxLogLevel.error, "Expected correct log level")
    }
    
    func testLogLevelHierarchyWarning() throws {
        let l = BlxLogger.instance
        BlxLogger.logLevel = .warning
        l.log("A debug message", level: .debug)
        l.log("A warning message", level: .warning)
        l.log("An error message", level: .error)
    
        let all = l.entries.toArray()
        let expectedCount = 2
        XCTAssertEqual(all.count, expectedCount, "Expected exactly \(expectedCount) entries")
        XCTAssertEqual(all[0].level, BlxLogLevel.warning, "Expected correct log level")
        XCTAssertEqual(all[1].level, BlxLogLevel.error, "Expected correct log level")
    }

}
