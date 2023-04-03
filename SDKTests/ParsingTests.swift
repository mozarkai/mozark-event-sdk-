//
//  ParsingTests.swift
//  MozarkEventsSDKTests
//
//  Created by Mohamed Ali BELHADJ on 01/03/2023.
//
import XCTest
@testable import MozarkEventsSDK

final class ParsingTests: XCTestCase {
    static let capturedEvent = MozarkEvents(sendRealTimeEvents: false, eventURL: "https://development-api.mozark.ai", applicationName: "default_ios_app_name", applicationId: "com.hotstar.mobile", applicationVersion: "default_ios_app_version")
    override func setUp() {
        continueAfterFailure = false
        ParsingTests.capturedEvent.eventsData.removeAll()
    }
    override class func tearDown() {
        print("Called after all Tests")
    }
    
    func testMozarkAttributes() {
        let mozarkDict : [String:Any] = ParsingTests.capturedEvent.updateMozarkDictAttributes(mozarkEventAttributes: ["key":"value"], attributesKey: "otherKey", attributesValue: "otherValue", defaultValue: ParsingTests.capturedEvent.defaultEventAttribute.applicationName)
        XCTAssert(mozarkDict["key"] as? String == "value", "first dict (mozarkEventAttributes) not getted")
        XCTAssert(mozarkDict["otherKey"] as? String == "otherValue", "new value not setted")
    }
    func testGetUpdateMozarkEventAttributesDict()
    {
        let mozarkDict : [String:Any] = ParsingTests.capturedEvent.getUpdateMozarkEventAttributesDict(mozarkEventAttributes: ["key":"value"], journeyName: "test journey")
        XCTAssert(mozarkDict["key"] as? String == "value", "first dict (mozarkEventAttributes) not getted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.applicationName.rawValue],"application name not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.applicationId.rawValue],"application id not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.applicationVersion.rawValue],"application version not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.testId.rawValue],"testId not setted")

    }
    
    func testCheckDataInFileAndFromUserData()
    {
        let mozarkDict : [String:Any] = ParsingTests.capturedEvent.checkDataInFileAndFromUserData(updatedMozarkEventAttributes: ["key":"value"])
        XCTAssert(mozarkDict["key"] as? String == "value", "first dict (mozarkEventAttributes) not getted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.testStatus.rawValue],"testStatus not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.projectName.rawValue],"projectName not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.scriptId.rawValue],"scriptId not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.deviceMake.rawValue],"deviceMake not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.deviceModel.rawValue],"deviceModel not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.devicePlatform.rawValue],"devicePlatform not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.devicePlatformVersion.rawValue],"devicePlatformVersion not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.deviceCountry.rawValue],"deviceCountry not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.deviceLocation.rawValue],"deviceLocation not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.userName.rawValue],"userName not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.browserName.rawValue],"browserName not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.browserVersion.rawValue],"browserVersion not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.deviceNetworkType.rawValue],"deviceNetworkType not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.operatorr.rawValue],"operatorr not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.deviceMobileNetworkTechnology.rawValue],"deviceMobileNetworkTechnology not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.deviceCityFromGeoCode.rawValue],"deviceCityFromGeoCode not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.deviceCityFromIsp.rawValue],"deviceCityFromIsp not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.deviceCellularNetworkId.rawValue],"deviceCellularNetworkId not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.additionalInfo1.rawValue],"additionalInfo1 not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.additionalInfo2.rawValue],"additionalInfo2 not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.additionalInfo3.rawValue],"additionalInfo3 not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.additionalInfo4.rawValue],"additionalInfo4 not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.additionalInfo4.rawValue],"additionalInfo4 not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.testCaseName.rawValue],"testCaseName not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.deviceSerial.rawValue],"deviceSerial not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.downloadSpeed.rawValue],"downloadSpeed not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.downloadSpeedBucket.rawValue],"downloadSpeedBucket not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.eventUrl.rawValue],"eventUrl not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.uploadSpeed.rawValue],"uploadSpeed not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.downloadSpeed.rawValue],"downloadSpeed not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.userId.rawValue],"userId not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.uploadSpeedBucket.rawValue],"uploadSpeedBucket not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.testStartTime.rawValue],"testStartTime not setted")
        XCTAssertNotNil(mozarkDict[MozarkAttributeKeys.userId.rawValue],"userId not setted")
    }
    func testGetHostDict()
    {
        let hostDict:[String:Any]? = ParsingTests.capturedEvent.getHostDict(request: URLRequest(url: URL(string: "https://development-api.mozark.ai")!), resultDict: ["status":"ok"])
        XCTAssertNotNil(hostDict,"we have result nil")
        XCTAssert(hostDict?[MozarkAttributeKeys.status.rawValue] as? String == "ok", "invalid status code")
        XCTAssert(hostDict?[MozarkAttributeKeys.response.rawValue] as? String == "200", "invalid response code")
        XCTAssertNotNil(hostDict?[MozarkAttributeKeys.timeStamp.rawValue],"timeStamp not setted")

    }
    func testUpadateUserDefaultAttributes()
    {
        let updatedMozarkDict : [String:Any] = ParsingTests.capturedEvent.upadateUserDefaultAttributes(eventAttributes: ["key":"value"])
        XCTAssert(updatedMozarkDict["key"] as? String == "value", "first dict (mozarkEventAttributes) not getted")
        let mozarkDict :[String:Any]? = updatedMozarkDict[MozarkAttributeKeys.mozarkEventAttributes.rawValue] as? [String : Any]
        XCTAssertNotNil(mozarkDict,"event dict not setted")
        XCTAssert(mozarkDict?[MozarkAttributeKeys.applicationName.rawValue] as? String == ParsingTests.capturedEvent.applicationName, "application name not setted")
        XCTAssert(mozarkDict?[MozarkAttributeKeys.applicationVersion.rawValue] as? String == ParsingTests.capturedEvent.applicationVersion, "application version not setted")
        XCTAssert(mozarkDict?[MozarkAttributeKeys.applicationId.rawValue] as? String == ParsingTests.capturedEvent.applicationId, "application id not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.uuid.rawValue],"uuid not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.testId.rawValue],"testId not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.testStatus.rawValue],"testStatus not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.projectName.rawValue],"projectName not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.scriptId.rawValue],"scriptId not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.deviceMake.rawValue],"deviceMake not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.deviceModel.rawValue],"deviceModel not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.devicePlatform.rawValue],"devicePlatform not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.devicePlatformVersion.rawValue],"devicePlatformVersion not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.deviceCountry.rawValue],"deviceCountry not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.deviceLocation.rawValue],"deviceLocation not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.userName.rawValue],"userName not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.browserName.rawValue],"browserName not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.browserVersion.rawValue],"browserVersion not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.deviceNetworkType.rawValue],"deviceNetworkType not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.operatorr.rawValue],"operatorr not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.deviceMobileNetworkTechnology.rawValue],"deviceMobileNetworkTechnology not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.deviceCityFromGeoCode.rawValue],"deviceCityFromGeoCode not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.deviceCityFromIsp.rawValue],"deviceCityFromIsp not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.deviceCellularNetworkId.rawValue],"deviceCellularNetworkId not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.additionalInfo1.rawValue],"additionalInfo1 not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.additionalInfo2.rawValue],"additionalInfo2 not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.additionalInfo3.rawValue],"additionalInfo3 not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.additionalInfo4.rawValue],"additionalInfo4 not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.additionalInfo4.rawValue],"additionalInfo4 not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.testCaseName.rawValue],"testCaseName not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.deviceSerial.rawValue],"deviceSerial not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.downloadSpeed.rawValue],"downloadSpeed not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.downloadSpeedBucket.rawValue],"downloadSpeedBucket not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.eventUrl.rawValue],"eventUrl not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.uploadSpeed.rawValue],"uploadSpeed not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.downloadSpeed.rawValue],"downloadSpeed not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.userId.rawValue],"userId not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.orderId.rawValue],"orderId not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.uploadSpeedBucket.rawValue],"uploadSpeedBucket not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.testStartTime.rawValue],"testStartTime not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.HttpsApiResult.rawValue],"httpsApiResult not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.testEndTime.rawValue],"testEndTime not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.testStartDateTime.rawValue],"testStartDateTime not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.testEndDateTime.rawValue],"testEndDateTime not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.testEndTime.rawValue],"testEndTime not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.testEndTime.rawValue],"testEndTime not setted")
        XCTAssertNotNil(mozarkDict?[MozarkAttributeKeys.timeStamp.rawValue],"timeStamp not setted")

    }
    func testGetEventStatus()
    {
        let eventStatus : String = ParsingTests.capturedEvent.getEventStatus(eventsAttributes: ["eventAttributes" : ["startEvent": "Yes"]], eventName: "startEvent")
        XCTAssert(!eventStatus.isEmpty, "the status vent must not be empty")
        XCTAssert(eventStatus == "Yes", "the status vent must not be equal to event value in this case")

    }
    func testCombineData()
    {
        DispatchQueue.global().async(flags: .barrier) {
            let eventDataCount = ParsingTests.capturedEvent.eventsData.count
            ParsingTests.capturedEvent.combineData(eventAttributes: ["eventName": "startEvent"])
            XCTAssert(ParsingTests.capturedEvent.eventsData.count>eventDataCount,"eventsData is not incremented")
        }
    }
    func testParseSendEventResponse()
    {
        let eventResponse = ParsingTests.capturedEvent.eventResponse
        ParsingTests.capturedEvent.parseSendEventResponse(data: nil, response: nil, error: nil, eventName: "startEvent")
        XCTAssert(ParsingTests.capturedEvent.eventResponse>eventResponse,"eventsResponse is not incremented")
    }
}
