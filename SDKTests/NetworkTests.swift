//
//  NetworkTests.swift
//  AnalyticsSDKTests
//
//  Created by Mohamed Ali BELHADJ on 27/02/2023.
//

import XCTest
@testable import MozarkEventsSDK

final class NetworkTests: XCTestCase {
    
    static let capturedEvent = MozarkEvents(sendRealTimeEvents: false, eventURL: "https://development-api.mozark.ai", applicationName: "default_ios_app_name", applicationId: "com.hotstar.mobile", applicationVersion: "default_ios_app_version")
    static let eventAttributes: [String:Any] =  NetworkTests.capturedEvent.getEventDictUpdated(eventName: "startEvent", journeyName: "start", eventValue: "Yes",othersEventAttributes: nil)
    static var joinAttributes : [String:Any] { NetworkTests.capturedEvent.getJoinedDictUpdated(eventName: "startEvent",eventAttributes:self.eventAttributes)}
    override func setUp() {
        continueAfterFailure = false
        var eventAttributes = EventDefaultAttributes()
        eventAttributes.testStatus = "Test Dev-J1"
        NetworkTests.capturedEvent.defaultEventAttribute = eventAttributes
        print("setUp")
    }
    override class func tearDown() {
        print("Called after all Tests")
    }
    func testSpeed() {
        var response = false
        let speedExpection = expectation(description: "speedTest")
            NetworkTests.capturedEvent.updateDownloadSpeed { success in
                response = success
                speedExpection.fulfill()
            }
        waitForExpectations(timeout: 2) { _ in
            XCTAssert(response == true,"test speed api does not work")
        }
    }
    func testRequestsArray() {
        let baseUrl = URL(string: MozarkEventsConstants.Link.hotStarBaseUrl)
        XCTAssertNotNil(baseUrl,"base Url does not conform")
        let hostArray = MozarkEventsConstants.Link.hostArray
        XCTAssertTrue(!hostArray.isEmpty,"hostArray is empty")
        XCTAssert(hostArray.count == NetworkTests.capturedEvent.getRequestsArray().count, "we have requests not added to final requestsArray")
        for hostItem in hostArray {
            XCTAssertNotNil(URL(string: MozarkEventsConstants.Link.hotStarBaseUrl + hostItem),"URL does not conform")
        }
    }
    func testPingHosts()
    {
        var response = false
        let pingExpection = expectation(description: "pingHosts")
        NetworkTests.capturedEvent.pingHostsAndSendEventAttributesToServer(attributes: NetworkTests.joinAttributes) { success in
                response = success
            pingExpection.fulfill()
            }
        waitForExpectations(timeout: 15) { _ in
            XCTAssert(response == true,"ping hosts api does not work")
        }
    }
    func testSpeedBucket() {
        let speed = "2"
        let speedF = Float(speed)
        XCTAssertNotNil(speedF,"speed params is not number (Int,Float,Double...)")
        XCTAssert(NetworkTests.capturedEvent.speedBucket(speed: speed) == "2 to 4","speed bucket method does not work well")
    }
    func testSendOneEvent()
    {
        var response = false
        let sendEventExpection = expectation(description: "sendEvent")
        do
        {
            let jsonData = try JSONSerialization.data(withJSONObject: NetworkTests.joinAttributes, options: .prettyPrinted)
            NetworkTests.capturedEvent.sendEvent(encoded: jsonData, eventName: "startEvent") { success in
                response = success
                sendEventExpection.fulfill()
            }
        }
        catch let error {
            print(error)
        }
        waitForExpectations(timeout: 5) { _ in
            XCTAssert(response == true,"Send Event api does not work")
        }
    }
    func testSendEventHard()
    {
        EventTests.capturedEvent.eventDiscarded = 0
        EventTests.capturedEvent.eventsData.removeAll()
        for _ in 1...5
        {
            let eventAttributes: [String:Any] = EventTests.capturedEvent.getEventDictUpdated(eventName: "startEvent", journeyName: "start", eventValue: "Yes",othersEventAttributes: nil)
            let joinAttributes : [String:Any] = EventTests.capturedEvent.getJoinedDictUpdated(eventName: "startEvent",eventAttributes:eventAttributes)
            EventTests.capturedEvent.eventsData.append(joinAttributes)
        }
        var response = false
        let sendEventExpection = expectation(description: "sendEventHard")
            NetworkTests.capturedEvent.sendEventsHard { success in
                response = success
                sendEventExpection.fulfill()
            }
        waitForExpectations(timeout: 5) { _ in
            XCTAssert(response == true,"Send Event hard api does not work")
        }
    }
    func testSendAllEvents()
    {
        NetworkTests.capturedEvent.eventDiscarded = 0
        NetworkTests.capturedEvent.eventsData.removeAll()
        for _ in 1...NetworkTests.capturedEvent.maxBatchSize-1
        {
            let eventAttributes: [String:Any] = EventTests.capturedEvent.getEventDictUpdated(eventName: "startEvent", journeyName: "start", eventValue: "Yes",othersEventAttributes: nil)
            let joinAttributes : [String:Any] = EventTests.capturedEvent.getJoinedDictUpdated(eventName: "startEvent",eventAttributes:eventAttributes)
            NetworkTests.capturedEvent.eventsData.append(joinAttributes)
        }
        var response = false
        let sendEventExpection = expectation(description: "sendAllEvents")
            NetworkTests.capturedEvent.sendAllEvents { success in
                response = success
                sendEventExpection.fulfill()
            }
        waitForExpectations(timeout: 60) { _ in
            XCTAssert(response == true,"Send All Event api does not work")
        }
    }
    func testSendRealTimeEvents()
    {
        NetworkTests.capturedEvent.eventDiscarded = 0
        NetworkTests.capturedEvent.eventsData.removeAll()
        for _ in 1...70
        {
            let eventAttributes: [String:Any] = EventTests.capturedEvent.getEventDictUpdated(eventName: "startEvent", journeyName: "start", eventValue: "Yes",othersEventAttributes: nil)
            let joinAttributes : [String:Any] = EventTests.capturedEvent.getJoinedDictUpdated(eventName: "startEvent",eventAttributes:eventAttributes)
            NetworkTests.capturedEvent.eventsData.append(joinAttributes)
        }
        var response = false
        let sendEventExpection = expectation(description: "sendAllEvents")
            NetworkTests.capturedEvent.sendEventsRealtime { success in
                response = success
                sendEventExpection.fulfill()
            }
        waitForExpectations(timeout: 15) { _ in
            XCTAssert(response == true,"Send All Event api does not work")
        }
    }
}
