//
//  SDKTests.swift
//  SDKTests
//
//  Created by Jagdish Prajapati on 18/11/22.
//

import XCTest
@testable import MozarkEventsSDK


final class SDKTests: XCTestCase {

   static let capturedEvent = MozarkEvents(sendRealTimeEvents: false, eventURL: "https://development-api.mozark.ai", applicationName: "default_ios_app_name", applicationId: "com.hotstar.mobile", applicationVersion: "default_ios_app_version")

    override func setUp() {
        continueAfterFailure = false
        var eventAttributes = EventDefaultAttributes()
        eventAttributes.testStatus = "Test Dev-J1"
        SDKTests.capturedEvent.defaultEventAttribute = eventAttributes
    }
    override class func tearDown() {
        print("Called after all Tests")
    }
    
    func testParamtersGettedAfterInit()
    {
        XCTAssert(SDKTests.capturedEvent.applicationName == "default_ios_app_name", "Error set application name")
        XCTAssert(SDKTests.capturedEvent.applicationId == "com.hotstar.mobile", "Error set application id")
        XCTAssert(SDKTests.capturedEvent.applicationVersion == "default_ios_app_version", "Error set application version")
        XCTAssert(SDKTests.capturedEvent.eventURL == "https://development-api.mozark.ai", "Error set eventUrl")
        XCTAssert(SDKTests.capturedEvent.sendRealTimeEvents == false, "Error set sendRealTimeEvents")
    }
    func testEventAttributedMerged() {
        
        let joinAttributes : [String:Any] = SDKTests.capturedEvent.getJoinedDictUpdated(eventName: "startEvent",eventAttributes: ["homeElementHotLaunch":"yes"])
        XCTAssertNotNil(joinAttributes["eventAttributes"], "eventAttributes not setted")
        let eventDict:[String:Any] = joinAttributes["eventAttributes"] as! [String : Any]
        XCTAssertNotNil(eventDict["homeElementHotLaunch"],"Error to set externals attributes")
        XCTAssert(eventDict["homeElementHotLaunch"] as! String == "yes","Error to set value for external key")
        XCTAssertNotNil(joinAttributes["eventName"],"Error to set internals attributes")
        XCTAssert(joinAttributes["eventName"] as! String == "startEvent","Error to set value for internals key")

        let eventAttributes: [String:Any] = SDKTests.capturedEvent.getEventDictUpdated(eventName: "startEvent", journeyName: "start", eventValue: "Yes",othersEventAttributes: ["homeElementHotLaunch":"yes"])
        XCTAssertNotNil(eventAttributes["homeElementHotLaunch"],"Error to set externals attributes")
        XCTAssert(eventAttributes["homeElementHotLaunch"] as! String=="yes","Error to set value for external key")
        XCTAssertNotNil(eventAttributes["dateTime"],"the dateTime attribute must not be nil")
        XCTAssertNotNil(eventAttributes["testCaseName"],"the testCaseName attribute must not be nil")
        XCTAssert(eventAttributes["testCaseName"] as! String == "start","Error to set testCaseName")
        XCTAssert(eventAttributes["startEvent"] as! String == "Yes","Error to set value to eventName attributes")
        
    }
    func testGetMozarkEventsDataFromFile() {
       let mozarkAttributesDict =  SDKTests.capturedEvent.getMozarkEventsDataFromJsonEmbeddedFile()
        XCTAssertNotNil(mozarkAttributesDict,"mozarkDict must be not nil")
    }
}
