//
//  MozarkEvents+Parsing.swift
//  SDK
//
//  Created by Mohamed Ali BELHADJ on 15/02/2023.
//

import Foundation
extension MozarkEvents
{
    /// Update the value of one of the keys in mozark json file
    ///  - Parameter mozarkEventAttributes:mozark attributes getted from json file
    ///  - Parameter attributesKey:json attributes key
    ///  - Parameter attributesValue:new value
    ///  - Returns Dictionnary after update
    internal func updateMozarkDictAttributes(mozarkEventAttributes:[String:Any],attributesKey:String,attributesValue:String?,defaultValue:String)->[String:Any]
    {
        var updatedMozarkEventAttributes = mozarkEventAttributes
        if let value = attributesValue
        {
            if attributesValue != ""
            {
                updatedMozarkEventAttributes[attributesKey]  = value
            }
            else
            {
                if updatedMozarkEventAttributes[attributesKey] == nil || updatedMozarkEventAttributes[attributesKey] as? String == ""
                {
                    updatedMozarkEventAttributes[attributesKey]  = defaultValue
                }
            }
        }
        else
        {
            if updatedMozarkEventAttributes[attributesKey] == nil || updatedMozarkEventAttributes[attributesKey] as? String == ""
            {
                updatedMozarkEventAttributes[attributesKey]  = defaultValue
            }
        }
        return updatedMozarkEventAttributes
    }
    /// Update the content of mozark attributes files with app coordinates
    ///  - Parameter mozarkEventAttributes:mozark attributes getted from json file
    ///  - Parameter journeyName:journey name or test case name
    ///  - Returns Dictionnary after update
    internal func getUpdateMozarkEventAttributesDict(mozarkEventAttributes:[String:Any],journeyName:String? = nil) -> [String:Any]
    {
        var updatedMozarkEventAttributes = mozarkEventAttributes
        updatedMozarkEventAttributes = self.updateMozarkDictAttributes(mozarkEventAttributes: updatedMozarkEventAttributes, attributesKey: MozarkAttributeKeys.applicationName.rawValue, attributesValue: self.applicationName,defaultValue: self.defaultEventAttribute.applicationName)
        updatedMozarkEventAttributes = self.updateMozarkDictAttributes(mozarkEventAttributes: updatedMozarkEventAttributes, attributesKey: MozarkAttributeKeys.applicationVersion.rawValue, attributesValue: self.applicationVersion,defaultValue: self.defaultEventAttribute.applicationVersion)
        updatedMozarkEventAttributes = self.updateMozarkDictAttributes(mozarkEventAttributes: updatedMozarkEventAttributes, attributesKey: MozarkAttributeKeys.applicationId.rawValue, attributesValue: self.applicationId,defaultValue: self.defaultEventAttribute.applicationId)
        updatedMozarkEventAttributes = self.updateMozarkDictAttributes(mozarkEventAttributes: updatedMozarkEventAttributes, attributesKey: MozarkAttributeKeys.testId.rawValue, attributesValue: self.testId,defaultValue: self.defaultEventAttribute.testId)
        updatedMozarkEventAttributes[MozarkAttributeKeys.uuid.rawValue] = self.self.defaultEventAttribute.uuid

        if let location = currentLocation
        {
            updatedMozarkEventAttributes[MozarkAttributeKeys.deviceLocation.rawValue] = String(format: "%.2f,%.2f", location.coordinate.latitude,location.coordinate.longitude)

        }
        if let opertorName = self.getOperatorName()
        {
            updatedMozarkEventAttributes[MozarkAttributeKeys.deviceMobileOperator.rawValue] = opertorName
        }
        if let testCaseName = journeyName
        {
            updatedMozarkEventAttributes[MozarkAttributeKeys.testCaseName.rawValue] = testCaseName
        }

        return self.checkDataInFileAndFromUserData(updatedMozarkEventAttributes: updatedMozarkEventAttributes)
    }
    /// Get event URL and event test identifier from json file
    /// - Returns Dictionnary contain event URL and event test identifier
    internal func getEventCoordinates(){
        // Check if mozark Json file is valid
            guard let eventDict = self.mozarkAttributesDict else {
            return
        }
        // Get Event URL
        if let apiUrl = eventDict[MozarkAttributeKeys.eventUrl.rawValue]
        {
            self.eventURL = apiUrl as? String
        }
        // Get Event testId
        if let eventTestId = eventDict[MozarkAttributeKeys.testId.rawValue]
        {
            self.testId = eventTestId as?  String
        }
    }
    /// Update events list to synchronise with server
    ///  - Parameter eventAttributes:Event's attributes to store
    internal func synchroniseAttributesLocally(eventName: String, eventValue: String,journeyName: String,othersEventAttributes:[String:Any]? = nil)  {
        let eventAttributes : [String:Any] = self.getEventDictUpdated(eventName: eventName, journeyName: journeyName, eventValue: eventValue,othersEventAttributes: othersEventAttributes)
        var joinAttributes : [String:Any] = self.getJoinedDictUpdated(eventName: eventName,eventAttributes: eventAttributes)
        if let mozarkEventAttributesDict = self.mozarkAttributesDict{
            let modifiedDict  = self.getUpdateMozarkEventAttributesDict(mozarkEventAttributes: mozarkEventAttributesDict,journeyName:journeyName)
            joinAttributes["mozarkEventAttributes"] = modifiedDict
            //add event attributes to events array to synchronise
            self.combineData(eventAttributes: joinAttributes)
            self.writeToLog(s: "==== check event data === \(modifiedDict)")
        }
        else
        {
            // update array of event and log error
            self.treatMozarkAttributeParseError(eventsAttributsDict: joinAttributes,logString: "FILE PATH NOT AVAILABLE")
        }
    }
    /// Update list of events to synchronise and log error
    ///  - Parameter eventAttributes:Event's attributes to store
    ///  - Parameter logString:log to leave
    internal func treatMozarkAttributeParseError(eventsAttributsDict:[String:Any],logString:String)
    {
        let objectData = self.upadateUserDefaultAttributes(eventAttributes: eventsAttributsDict)
        self.combineData(eventAttributes: objectData)
        self.writeToLog(s: "FILE PATH NOT AVAILABLE")
    }
    /// Update the content of mozark attributes files with new coordinates (download speed valuen ping status, list of hosts called...)
    ///  - Parameter attributes:events attributes
    ///  - Parameter dictionary:mozark attributes getted from json file
    ///  - Parameter hosts:dictionnary contain hosts called and response status
    ///  - Returns Dictionnary after update
    internal func updateMozarkAttributsDictForPingCase(attributes : [String:Any],mozarkDictionary:[String:Any],hosts:[[String:Any]]) -> [String:Any]
    {
        var mozarkAttributes = attributes
        var mozarkDictionary = mozarkDictionary
        let speed = self.getNetSpeed()
        
        mozarkDictionary[MozarkAttributeKeys.downloadSpeed.rawValue] = speed // "6.56" //
        mozarkDictionary[MozarkAttributeKeys.downloadSpeedBucket.rawValue] = self.speedBucket(speed:speed)
        mozarkDictionary[MozarkAttributeKeys.HttpsApiResult.rawValue] = hosts
        mozarkDictionary[MozarkAttributeKeys.response.rawValue] = "200"
        mozarkDictionary[MozarkAttributeKeys.status.rawValue] = "test"
        mozarkAttributes[MozarkAttributeKeys.mozarkEventAttributes.rawValue] = self.getUpdateMozarkEventAttributesDict(mozarkEventAttributes: mozarkDictionary)
        
        self.writeToLog(s: "==== check ping event data === \([mozarkAttributes])")
        return mozarkAttributes
    }
    /// Get host dictionnary after call host
    ///  - Parameter request:used just to get host URL
    ///  - Parameter resultDict:Dictionnary returned following host call
    ///  - Returns Dictionnary after update
    func getHostDict(request:URLRequest,resultDict:[String: Any])->[String: Any]?
    {
        let timestamp =  "\(UInt64(floor(Date().timeIntervalSince1970 * 1000)))"
        let host :String = (request.url?.absoluteString.replacingOccurrences(of: MozarkEventsConstants.Link.hotStarBaseUrl, with: "", options: [.caseInsensitive, .regularExpression]))!
        if let statusCode = resultDict[MozarkAttributeKeys.status.rawValue]
        {
            guard statusCode is String else {
                return nil
            }
            let reponsecode = statusCode as! String == "ok" ? "200" : "500"
            return [MozarkAttributeKeys.status.rawValue:statusCode,MozarkAttributeKeys.host.rawValue:host,MozarkAttributeKeys.response.rawValue:reponsecode,MozarkAttributeKeys.timeStamp.rawValue:timestamp]
        }
        return nil
    }
    /// Browse the values of each key from json file dict, if a key does not have a value, it is assigned a default value
    ///  - Parameter updatedMozarkEventAttributes : dictionnary contain all data who is registered in json file stored in documents directory
    ///  - Returns Dictionnary after update
    
    func checkDataInFileAndFromUserData(updatedMozarkEventAttributes:[String:Any]) -> [String:Any]{
        var modifiedDict =  updatedMozarkEventAttributes
       
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.testStatus.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.testStatus.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.testStatus.rawValue]  = self.defaultEventAttribute.testStatus
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.projectName.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.projectName.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.projectName.rawValue]  = self.defaultEventAttribute.projectName
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.scriptId.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.scriptId.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.scriptId.rawValue]  = self.defaultEventAttribute.scriptId
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.deviceMake.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.deviceMake.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.deviceMake.rawValue]  = self.defaultEventAttribute.deviceMake
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.deviceModel.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.deviceModel.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.deviceModel.rawValue]  = self.defaultEventAttribute.deviceModel
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.devicePlatform.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.devicePlatform.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.devicePlatform.rawValue]  = self.defaultEventAttribute.devicePlatform
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.devicePlatformVersion.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.devicePlatformVersion.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.devicePlatformVersion.rawValue]  = self.defaultEventAttribute.devicePlatformVersion
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.city.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.city.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.city.rawValue]  = self.defaultEventAttribute.deviceCity
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.deviceCountry.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.deviceCountry.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.deviceCountry.rawValue]  = self.defaultEventAttribute.deviceCountry
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.deviceLocation.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.deviceLocation.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.deviceLocation.rawValue]  = self.defaultEventAttribute.deviceLocation
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.userName.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.userName.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.userName.rawValue]  = self.defaultEventAttribute.userName
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.browserName.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.browserName.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.browserName.rawValue]  = self.defaultEventAttribute.browserName
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.browserVersion.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.browserVersion.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.browserVersion.rawValue]  = self.defaultEventAttribute.browserVersion
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.deviceNetworkType.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.deviceNetworkType.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.deviceNetworkType.rawValue]  = self.defaultEventAttribute.deviceNetworkType
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.operatorr.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.operatorr.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.operatorr.rawValue]  = self.defaultEventAttribute.deviceMobileOperator
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.deviceMobileNetworkTechnology.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.deviceMobileNetworkTechnology.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.deviceMobileNetworkTechnology.rawValue]  = self.defaultEventAttribute.deviceMobileNetworkTechnology
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.deviceCityFromGeoCode.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.deviceCityFromGeoCode.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.deviceCityFromGeoCode.rawValue]  = self.defaultEventAttribute.deviceCityFromGeocode
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.deviceCityFromIsp.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.deviceCityFromIsp.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.deviceCityFromIsp.rawValue]  = self.defaultEventAttribute.deviceCityFromIsp
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.deviceCellularNetworkId.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.deviceCellularNetworkId.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.deviceCellularNetworkId.rawValue]  = self.defaultEventAttribute.deviceCellularNetworkId
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.additionalInfo1.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.additionalInfo1.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.additionalInfo1.rawValue]  = self.defaultEventAttribute.additionalInfo1
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.additionalInfo2.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.additionalInfo2.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.additionalInfo2.rawValue]  = self.defaultEventAttribute.additionalInfo2
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.additionalInfo3.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.additionalInfo3.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.additionalInfo3.rawValue]  = self.defaultEventAttribute.additionalInfo3
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.additionalInfo4.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.additionalInfo4.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.additionalInfo4.rawValue]  = self.defaultEventAttribute.additionalInfo4
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.additionalInfo5.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.additionalInfo5.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.additionalInfo5.rawValue]  = self.defaultEventAttribute.additionalIinfo5
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.testCaseName.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.testCaseName.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.testCaseName.rawValue]  = self.defaultEventAttribute.testCaseName
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.deviceSerial.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.deviceSerial.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.deviceSerial.rawValue]  = self.defaultEventAttribute.deviceId
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.downloadSpeed.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.downloadSpeed.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.downloadSpeed.rawValue]  = self.defaultEventAttribute.downloadSpeed
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.orderId.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.orderId.rawValue] as? Int == 0{
            modifiedDict[MozarkAttributeKeys.orderId.rawValue]  = self.defaultEventAttribute.orderId
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.eventUrl.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.eventUrl.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.eventUrl.rawValue]  = self.defaultEventAttribute.eventUrl
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.uploadSpeed.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.uploadSpeed.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.uploadSpeed.rawValue]  = self.defaultEventAttribute.uploadSpeed
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.downloadSpeedBucket.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.downloadSpeedBucket.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.downloadSpeedBucket.rawValue]  = self.defaultEventAttribute.downloadSpeedBucket
        }
        
        if updatedMozarkEventAttributes[MozarkAttributeKeys.userId.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.userId.rawValue] as? Int == 0{
            modifiedDict[MozarkAttributeKeys.userId.rawValue]  = self.defaultEventAttribute.userId
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.uploadSpeedBucket.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.uploadSpeedBucket.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.uploadSpeedBucket.rawValue]  = self.defaultEventAttribute.uploadSpeedBucket
        }
        if updatedMozarkEventAttributes[MozarkAttributeKeys.testStartTime.rawValue] == nil || updatedMozarkEventAttributes[MozarkAttributeKeys.testStartTime.rawValue] as? String == ""{
            modifiedDict[MozarkAttributeKeys.testStartTime.rawValue]  = Date().convertToISOString()
        }
        
        return modifiedDict
    }
    /// Browse the values of each key from event attributes dict, if a key does not have a value, it is assigned a default value
    ///  - Parameter eventAttributes : dictionnary contain event attributes
    ///  - Returns Dictionnary after update
    func upadateUserDefaultAttributes(eventAttributes:[String:Any]) -> [String:Any]{
        let defaultAttrib =  self.defaultEventAttribute
        var orginalEventAttributes = eventAttributes
        var myDictionary = [String:Any]()
        myDictionary[MozarkAttributeKeys.applicationName.rawValue]  = self.applicationName ?? defaultAttrib.applicationName
        myDictionary[MozarkAttributeKeys.applicationId.rawValue] = self.applicationId ?? defaultAttrib.applicationId
        myDictionary[MozarkAttributeKeys.applicationVersion.rawValue] = self.applicationVersion ?? defaultAttrib.applicationVersion
        myDictionary[MozarkAttributeKeys.uuid.rawValue]  = defaultAttrib.uuid
        myDictionary[MozarkAttributeKeys.testId.rawValue]  = defaultAttrib.testId
        myDictionary[MozarkAttributeKeys.testStatus.rawValue]  = defaultAttrib.testStatus
        myDictionary[MozarkAttributeKeys.projectName.rawValue]  = defaultAttrib.projectName
        myDictionary[MozarkAttributeKeys.scriptId.rawValue]  = defaultAttrib.scriptId
        myDictionary[MozarkAttributeKeys.deviceMake.rawValue]  = defaultAttrib.deviceMake
        myDictionary[MozarkAttributeKeys.deviceModel.rawValue]  = defaultAttrib.deviceModel
        myDictionary[MozarkAttributeKeys.devicePlatform.rawValue]  = defaultAttrib.devicePlatform
        myDictionary[MozarkAttributeKeys.devicePlatformVersion.rawValue]  = defaultAttrib.devicePlatformVersion
        myDictionary[MozarkAttributeKeys.deviceCity.rawValue]  = defaultAttrib.deviceCity
        myDictionary[MozarkAttributeKeys.city.rawValue]  = defaultAttrib.city
        myDictionary[MozarkAttributeKeys.deviceCountry.rawValue]  = defaultAttrib.deviceCountry
        myDictionary[MozarkAttributeKeys.deviceLocation.rawValue]  = defaultAttrib.deviceLocation
        myDictionary[MozarkAttributeKeys.userName.rawValue]  = defaultAttrib.userName
        myDictionary[MozarkAttributeKeys.browserName.rawValue]  = defaultAttrib.browserName
        myDictionary[MozarkAttributeKeys.browserVersion.rawValue]  = defaultAttrib.browserVersion
        myDictionary[MozarkAttributeKeys.deviceNetworkType.rawValue]  = defaultAttrib.deviceNetworkType
        myDictionary[MozarkAttributeKeys.operatorr.rawValue]  = defaultAttrib.deviceMobileOperator
        myDictionary[MozarkAttributeKeys.deviceMobileNetworkTechnology.rawValue]  = defaultAttrib.deviceMobileNetworkTechnology
        myDictionary[MozarkAttributeKeys.deviceCityFromGeoCode.rawValue]  = defaultAttrib.deviceCityFromGeocode
        myDictionary[MozarkAttributeKeys.deviceCityFromIsp.rawValue]  = defaultAttrib.deviceCityFromIsp
        myDictionary[MozarkAttributeKeys.deviceCellularNetworkId.rawValue]  = defaultAttrib.deviceCellularNetworkId
        myDictionary[MozarkAttributeKeys.additionalInfo1.rawValue]  = defaultAttrib.additionalInfo1
        myDictionary[MozarkAttributeKeys.additionalInfo2.rawValue]  = defaultAttrib.additionalInfo2
        myDictionary[MozarkAttributeKeys.additionalInfo3.rawValue]  = defaultAttrib.additionalInfo3
        myDictionary[MozarkAttributeKeys.additionalInfo4.rawValue]  = defaultAttrib.additionalInfo4
        myDictionary[MozarkAttributeKeys.additionalInfo5.rawValue]  = defaultAttrib.additionalIinfo5
        myDictionary[MozarkAttributeKeys.testCaseName.rawValue]  = defaultAttrib.testCaseName
        myDictionary[MozarkAttributeKeys.deviceSerial.rawValue]  = defaultAttrib.deviceSerial
        myDictionary[MozarkAttributeKeys.downloadSpeed.rawValue]  = defaultAttrib.downloadSpeed
        myDictionary[MozarkAttributeKeys.orderId.rawValue]  = defaultAttrib.orderId
        myDictionary[MozarkAttributeKeys.eventUrl.rawValue]  = defaultAttrib.eventUrl
        myDictionary[MozarkAttributeKeys.uploadSpeed.rawValue]  = defaultAttrib.uploadSpeed
        myDictionary[MozarkAttributeKeys.downloadSpeedBucket.rawValue]  = defaultAttrib.downloadSpeedBucket
        myDictionary[MozarkAttributeKeys.userId.rawValue]  = defaultAttrib.userId
        myDictionary[MozarkAttributeKeys.serialId.rawValue]  = defaultAttrib.deviceSerial
        myDictionary[MozarkAttributeKeys.uploadSpeedBucket.rawValue]  = defaultAttrib.uploadSpeedBucket
        myDictionary[MozarkAttributeKeys.HttpsApiResult.rawValue]  = defaultAttrib.httpsApiResult
        // why all dates are Date() ????
        myDictionary[MozarkAttributeKeys.testStartTime.rawValue]  =  Date().convertToISOString()
        myDictionary[MozarkAttributeKeys.testEndTime.rawValue]  = Date().convertToISOString()
        myDictionary[MozarkAttributeKeys.testStartDateTime.rawValue]  = Date().convertToISOString()
        myDictionary[MozarkAttributeKeys.testEndDateTime.rawValue]  = Date().convertToISOString()
        myDictionary[MozarkAttributeKeys.timeStamp.rawValue] = Double(Date().currentTimeMillis())
        orginalEventAttributes[MozarkAttributeKeys.mozarkEventAttributes.rawValue] = myDictionary
        return orginalEventAttributes as [String:Any]
    }
    /// Parse send event response
    ///  - Parameter data : data returned
    ///  - Parameter response : response returned
    ///  - Parameter error : error returned
    ///  - Parameter eventName : even's  name
    func parseSendEventResponse(data:Data?, response:URLResponse?, error:Error?,eventName:String)
    {
        self.eventResponse += 1
        // Check if data and response not nil
        guard let data = data,
              let response = response as? HTTPURLResponse,
              error == nil else {
            self.writeToLog(s: "---error---\(String(describing: error))")
            return
        }
        // Check if response status code between 200 and 299
        guard (200 ... 299) ~= response.statusCode else {
            self.writeToLog(s: "statusCode should be 2xx, but is \(response.statusCode)")
            self.writeToLog(s: "response = \(response)")
            self.writeToLog(s: "---data---")
            return
        }
        // Log event name and response value
        let responseString = String(data: data, encoding: .utf8)
        self.writeToLog(s: "responseString for \(eventName) = \(String(describing: responseString))")
        self.writeToLog(s: "APISendSucessFully:----")
        self.writeToLog(s: "---TaskDone---")
    }
    ///Add event attributes to event's array to synchronise with server
    /// - Parameter eventAttributes Dictionnary contain event's attributes
    func combineData(eventAttributes:[String:Any])
    {
        DispatchQueue.global().async(flags: .barrier) {
            if let eventName = eventAttributes[MozarkAttributeKeys.eventName.rawValue] as? String,eventName.isEmpty == false
            {
                // Check if event name is "loaderAppear"
                if eventName == "loaderAppear"
                {
                    if self.tempEventData.count > 0 {
                        
                        let currentEventStatus = self.getEventStatus(eventsAttributes: eventAttributes, eventName: "loaderAppear")
                        let previousStatus = self.getEventStatus(eventsAttributes: self.tempEventData.last!, eventName: "loaderAppear")
                        if previousStatus == currentEventStatus {
                            self.tempEventData.append(eventAttributes)
                        }else{
                            if self.tempEventData.count <= 2 {
                                for temp in self.tempEventData {
                                    self.eventsData.append(temp)
                                }
                            } else {
                                self.eventsData.append(self.tempEventData.first!)
                                self.eventsData.append(self.tempEventData.last!)
                                //Discard
                                for (a, _) in self.tempEventData.enumerated() {
                                    if a == 0 || a == self.tempEventData.count - 1 {
                                        //IGNORE first and last index of array
                                    } else {
                                        self.skipEventData.append(self.tempEventData[a])
                                    }
                                }
                            }
                            self.tempEventData.removeAll()
                            self.tempEventData.append(eventAttributes)
                        }
                    } else {
                        self.tempEventData.append(eventAttributes)
                    }
                }
                // Check if event name is "homeElementsAppear"
                else if eventName == "homeElementsAppear"
                {
                    let homeElementsAppearEventSta = self.getEventStatus(eventsAttributes: eventAttributes, eventName: "homeElementsAppear")
                    if homeElementsAppearEventSta == "Yes"{
                        self.eventsData.append(eventAttributes)
                        self.writeToLog(s: "homeElementsAppear found added")
                    }else{
                        self.writeToLog(s: "homeElementsAppear not added")
                    }
                }
                else
                {
                    // Add event's attributes to event's array to synchronise with server
                    self.eventsData.append(eventAttributes)
                }
            }
        }
    }
    /// Get events status
    ///  - Parameter eventsAttributes : Dictionnary contain all event's attributes
    ///  - Parameter eventName : Event's name
    ///  - Returns  Status string
    func getEventStatus(eventsAttributes:[String:Any],eventName:String) -> String {
        guard let eventData = eventsAttributes[MozarkAttributeKeys.eventAttributes.rawValue] as? [String:Any] else {return ""}
        guard let currentEventStatus = eventData[eventName] as? String else { return "" }
        return currentEventStatus
    }
}
