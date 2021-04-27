//
//  BlxLoggingFileStoreTests.swift
//  BlxLoggingTests
//
//  Created by Andreas Oetjen on 22.03.21.
//

import XCTest
@testable import BlxLogging

class BlxLoggingFileStoreTests: XCTestCase {

    override func setUpWithError() throws {
        let l = BlxLogger.instance
        l.clean()
        l.output = .none
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFileWrite() throws {
        let filename = "test1.log"
        let count = 5000
        let l = BlxLogger(logFileName: filename)
        l.output = .textFile
        l.clean()
        
        for i in 0..<count {
            l.logError("Error #\(i) occurred");
        }
        print ("waiting...")
        let wait = l.flushFile()
        print ("waited: \(wait)")
        let u = l.logFileUrl
        XCTAssertEqual(u.lastPathComponent, filename)
        let result = try? String(contentsOf: u)
        XCTAssertNotNil(result)
        guard let resultString = result else { return }
        var lines = resultString.components(separatedBy: "\n")
        lines.removeLast()
        let fileLineCount = lines.count
        XCTAssertEqual(count, fileLineCount, "Unexpected number of lines in log file")
        l.clean()
    }

    func testFileJson() throws {
        let filename = "test1.json"
        let count = 5000
        let l = BlxLogger(logFileName: filename)
        l.output = .jsonFile
        l.clean()
        
        for i in 0..<count {
            l.logError("Error #\(i) occurred");
        }
        print ("waiting...")
        let wait = l.flushFile()
        print ("waited: \(wait)")
        let u = l.logFileUrl
        XCTAssertEqual(u.lastPathComponent, filename)
        guard let result = try? Data(contentsOf: u) else {
            XCTFail("Unexpectedly found nil when loading data from file \(u)")
            return
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: result, options: []) as? [[String:Any]] else {
            XCTFail("Could not create json object")
            return
        }
        XCTAssertEqual(jsonObject.count, count, "Unexpected number of entries in log file")

        l.clean()
    }


}
