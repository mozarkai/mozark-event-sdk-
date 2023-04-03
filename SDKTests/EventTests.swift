//
//  EventTests.swift
//  MozarkEventsSDKTests
//
//  Created by Mohamed Ali BELHADJ on 28/02/2023.
//


import XCTest
@testable import MozarkEventsSDK

final class EventTests: XCTestCase {
    static let capturedEvent = MozarkEvents(sendRealTimeEvents: false, eventURL: "https://development-api.mozark.ai", applicationName: "default_ios_app_name", applicationId: "com.hotstar.mobile", applicationVersion: "default_ios_app_version")
    static let maxObjectToSendCount = EventTests.capturedEvent.writeEventDiscarded(maxCount: 50, tempEventsData: EventTests.capturedEvent.eventsData).count
    override func setUp() {
        continueAfterFailure = false
        EventTests.capturedEvent.startEventTimer()
        EventTests.capturedEvent.eventDiscarded = 0
        EventTests.capturedEvent.eventsData.removeAll()
        for _ in 1...70
        {
            let eventAttributes: [String:Any] = EventTests.capturedEvent.getEventDictUpdated(eventName: "startEvent", journeyName: "start", eventValue: "Yes",othersEventAttributes: nil)
            let joinAttributes : [String:Any] = EventTests.capturedEvent.getJoinedDictUpdated(eventName: "startEvent",eventAttributes: eventAttributes)
            EventTests.capturedEvent.eventsData.append(joinAttributes)
        }
    }
    override class func tearDown() {
        EventTests.capturedEvent.stopEventTimer()
        print("Called after all Tests")
    }
    func testLaunchTimer() {
        XCTAssertNotNil(EventTests.capturedEvent.eventTimer,"Error to init EventTimer")
        XCTAssert(EventTests.capturedEvent.eventTimer!.isValid, "Error to launchTimer")
        XCTAssert(EventTests.capturedEvent.timeValue == 0, "Time Value > 0")
    }
    func testStopTimer()
    {
        EventTests.capturedEvent.stopEventTimer()
        XCTAssertNil(EventTests.capturedEvent.eventTimer,"EventTimer is not nil")
        XCTAssert(EventTests.capturedEvent.timeValue == 0, "Time Value > 0")
    }
    func testWriteEventDiscarded() {
        let maxObjectToSend = EventTests.capturedEvent.writeEventDiscarded(maxCount: 50, tempEventsData: EventTests.capturedEvent.eventsData)
        XCTAssert(maxObjectToSend.count <= 51, "we have at most send 51 objects")
        XCTAssert(EventTests.capturedEvent.eventDiscarded <= 21, "the number of discarded vents is wrong")
    }
    func testGetEventDictUpdated()
    {
        let eventDictSingle:[String:Any] = EventTests.capturedEvent.getEventDictUpdated(eventName: "startEvent", journeyName: "start", eventValue: "Yes",othersEventAttributes: nil)
        XCTAssert(eventDictSingle["startEvent"] as? String == "Yes", "event value not setted")
        XCTAssert(eventDictSingle["testCaseName"] as? String == "start", "test case name not setted")
        XCTAssertNotNil(eventDictSingle["dateTime"], "dateTime not setted")
    }
    func testGetJoinedDictUpdated()
    {
        let joinedDict:[String:Any] = EventTests.capturedEvent.getJoinedDictUpdated(eventName: "startEvent",eventAttributes: ["eventTest":"test"])
        XCTAssert(joinedDict["eventName"] as? String == "startEvent", "event name not setted")
        XCTAssertNotNil(joinedDict["eventAttributes"], "eventAttributes not setted")
        let eventDict:[String:Any] = joinedDict["eventAttributes"] as! [String : Any]
        XCTAssert(eventDict["eventTest"] as? String == "test", "event Test (other attribute) not setted")
    }
}
