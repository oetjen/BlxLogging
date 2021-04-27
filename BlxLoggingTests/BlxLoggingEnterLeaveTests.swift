//
//  BxLoggingEnterLeaveTests.swift
//  BlxLoggingTests
//
//  Created by Andreas Oetjen on 22.03.21.
//

import XCTest
@testable import BlxLogging

class BlxLoggingEnterLeaveTests: XCTestCase {

    override func setUpWithError() throws {
        BlxFunctionCallTracker.instance.clean()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCallCount() throws {
        let expectedEntries = 132
        callSubroutines(maxDepth: 6)
        let history = BlxFunctionCallTracker.instance.history
        XCTAssertEqual(history.count, expectedEntries, "Wrong number of history entries")
        
        for e in history {
            print (e.shortDescription)
        }
    }
    
    func testCallNumbers() throws {
        let expectedEntries = 6
        let maxDepth = 3
        callSubroutines(maxDepth: maxDepth)
        let history = BlxFunctionCallTracker.instance.history
        
        XCTAssertEqual(history.count, expectedEntries, "Wrong number of history entries")

        let maxInx = history.count - 1
        for i in 0..<maxDepth {
            XCTAssertEqual(history[i].callNumber, history[maxInx-i].callNumber, "Call numbers of call at level \(i) do not match")

        }

        for e in history {
            print (e.shortDescription)
        }
    }
    func callSubroutines(maxDepth:Int) {
        let e = pEnter(); defer { pLeave(e) }
        callSub2(maxDepth-1)
    }
    func callSub2(_ level:Int) {
        let e = pEnter(); defer { pLeave(e) }
        if (level > 0) {
            for _ in 1..<level {
                callSub2(level-1)
            }
        }
    }
    
    func testOverrun() {
        let fct = BlxFunctionCallTracker.instance
        let loopCount = BlxFunctionCallTracker.maxEntries * 10 + 1
        for _ in 0..<loopCount {
            let e = pEnter(); pLeave(e)
        }
        XCTAssertEqual(fct.history.count, BlxFunctionCallTracker.maxEntries)
    }

   

}
