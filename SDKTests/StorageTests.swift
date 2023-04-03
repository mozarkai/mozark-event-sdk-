//
//  StorageTests.swift
//  MozarkEventsSDKTests
//
//  Created by Mohamed Ali BELHADJ on 24/02/2023.
//

import XCTest
@testable import MozarkEventsSDK

final class StorageTests: XCTestCase {
    static let capturedEvent = MozarkEvents(sendRealTimeEvents: false, eventURL: "https://development-api.mozark.ai", applicationName: "default_ios_app_name", applicationId: "com.hotstar.mobile", applicationVersion: "default_ios_app_version")
    
    override func setUp() {
        continueAfterFailure = false
    }
    override class func tearDown() {
        print("Called after all Tests")
    }
    func testGetLogFile() {
        let logPath : URL? = StorageTests.capturedEvent.getLogFilePath(fileName: "fileName")
        XCTAssertNotNil(logPath,"the path must not nil")
        XCTAssert(logPath?.lastPathComponent == "fileName", "lastPath must equal to fileName ")
    }
    func testGetFileName() {
        let fileName : String = StorageTests.capturedEvent.getLogFileName()
        XCTAssert(fileName.suffix(3) == "log", "file is not log file")
        let fileNameBasedOnDate : String = String(fileName.prefix(10))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate =  formatter.date(from: fileNameBasedOnDate)
        XCTAssertNotNil(currentDate,"filename is not date based")
        StorageTests.capturedEvent.getEventCoordinates()
        XCTAssertNotNil(StorageTests.capturedEvent.eventURL,"filename is not based on event url, event url is nil")
        XCTAssertNotNil(StorageTests.capturedEvent.testId,"filename is not based on event test id, eventTestId is nil")
        XCTAssert(fileName.substring(from: "_", to: ".log") == StorageTests.capturedEvent.testId, "filename is not based on event test id")
        XCTAssert(!fileName.substring(from: "_", to: ".log").isEmpty, "filename is not based on event test id, eventTestId empty")
    }
    func testPrepareEventsFileInDocumentsDirectory()
    {
        let sourceUrl = Bundle(for: type(of: self)).url(forResource: MozarkEventsConstants.Name.mozarkAttributesFileName, withExtension:"json")
        XCTAssertNotNil(sourceUrl,"Mozark json file not exist in ressources")
        StorageTests.capturedEvent.copyMozarkJsonFileToDocumentsDirectory()
        let jsonFilePath = StorageTests.capturedEvent.getMozarkJsonFilePath()
        XCTAssertNotNil(jsonFilePath,"Documents folder json file not exist")
        XCTAssert(FileManager.default.fileExists(atPath:jsonFilePath!),"Mozark json file not copied to Documents Directory")
        StorageTests.capturedEvent.createLogFile()
        let logFilePath = StorageTests.capturedEvent.getLogFilePath(fileName: StorageTests.capturedEvent.getLogFileName())
        XCTAssertNotNil(logFilePath,"Documents folder log file not exist")
        XCTAssert(FileManager.default.fileExists(atPath:logFilePath!.path),"Mozark json file not copied to Documents Directory")
    }
    func testWriteToInFile()
    {
        let logFilePath = StorageTests.capturedEvent.getLogFilePath(fileName: StorageTests.capturedEvent.getLogFileName())
        XCTAssertNotNil(logFilePath,"Documents folder log file not exist")
        XCTAssert(FileManager.default.fileExists(atPath:logFilePath!.path),"Mozark json file not copied to Documents Directory")
        StorageTests.capturedEvent.writeLogInFileAtPath(s: "Hi", logFilePath: logFilePath!)
        do {
            let logFileContent = try String(contentsOf: logFilePath!, encoding: .utf8)
            XCTAssert(!logFileContent.isEmpty,"log file empty")
            XCTAssert(logFileContent.suffix(2) == "Hi","Can't write in log file")
        }
        catch {}
    }
}
extension String {
    
    ///Returns an empty string when there is no path.
    func substring(from left: String, to right: String) -> String {
        if let match = range(of: "(?<=\(left))[^\(right)]+", options: .regularExpression) {
            return String(self[match])
        }
        return ""
    }
}
