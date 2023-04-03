//
//  MozarkEvents+Events.swift
//  SDK
//
//  Created by Mohamed Ali BELHADJ on 15/02/2023.
//

import Foundation
import CoreTelephony
import MozarkEventConstants
import CoreLocation

extension MozarkEvents
{
    ///Init sdk parameters
    internal func initilizeMozarkEventsFramework(sendRealTimeEvents: Bool,maxBatchSize:Int,batchTimeout : Int)
    {
        self.maxBatchSize = maxBatchSize
        self.batchTimeout = batchTimeout
        self.mozarkAttributesDict = self.getMozarkEventsDataFromJsonEmbeddedFile()
        // Create lof file + copy mozarkJson file To Documents folder
        self.prepareEventsFileInDocumentsDirectory()

        /// Write logs
        if let version = Bundle.main.releaseVersionNumber {
            writeToLog(s: "SDK Initialized with version = \(version)")
            writeToLog(s: "SDK Initialized with data = \(self.applicationName) b\(self.applicationId)")
        }
        writeToLog(s: "Send Real Time or Batch = \(sendRealTimeEvents)")
        if sendRealTimeEvents == true
        {
            //start event timer
            self.startEventTimer()
        }
        self.locationManager.delegate = self
        self.checkAuthorizationStatus()
    }
    
    /// Start timer
    internal func startEventTimer()
    {
        writeToLog(s: "Test Start Time = \(Double(Date().currentTimeMillis()))")
        self.eventTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(sendEventTimer), userInfo: nil, repeats: true)
        self.timeValue = 0
    }
    /// Stop timer
    internal func stopEventTimer()
    {
        self.timeValue = 0
        self.eventTimer?.invalidate()
        self.eventTimer = nil
    }
    /// Send the last events received during the last 5 seconds
    @objc internal func sendEventTimer() {
        // increase timevalue
        self.timeValue += 1
        // we send event evry 5 sec if sendRealTimeEvents == true
        if self.timeValue % 5 == 0 {
            if self.eventsData.count > 0 {
                self.sendEventsRealtime { success in
                }
            }
        }
    }
    /// Get events received and send them in real time
    /// - Parameter completion:completion handler, called when all events are sychnronized
    internal func sendEventsRealtime(completion:@escaping (_ success:Bool) -> Void) {
        // Get max 50 events to send put the rest as events discarded
        if self.sendRealTimeEventsInProgress == false
        {
            let maxObjectToSend = self.writeEventDiscarded(maxCount: 50, tempEventsData: self.eventsData)
            var eventsSend = 0
            let group = DispatchGroup()
            // Convert an array into arrays of 20 items
            let eventSubArrayObjects = maxObjectToSend.slice(size: 20)
            
            if  eventSubArrayObjects.count > 0 {
                self.sendRealTimeEventsInProgress = true
                // send item by item
                for (idx, _) in eventSubArrayObjects.enumerated() {
                    group.enter()
                    let eventObjects = eventSubArrayObjects[idx]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: eventObjects, options: .prettyPrinted)
                        //I tried to retrieve the eventName of the first object because we are sure that we have a minimum of one object per array and to validate
                        if eventObjects.count > 0
                        {
                            let eventDict = eventObjects[0]
                            // Convert events dictionnary to Data + and send them to the server
                            self.sendEvent(encoded: jsonData, eventName:eventDict[MozarkAttributeKeys.eventName.rawValue] as? String ?? ""){ success in
                                DispatchQueue.global().async(flags: .barrier) {
                                    if eventObjects.count > 0 && self.eventsData.count >= eventObjects.count
                                    {
                                        self.eventsData.removeSubrange(0...eventObjects.count - 1)
                                    }
                                    self.sendRealTimeEventsInProgress = false
                                }
                                eventsSend = eventsSend + 1
                                self.writeToLog(s: "eventSent \(eventsSend)")
                                DispatchQueue.global().async {
                                    group.leave()
                                }
                            }
                        }
                        
                    } catch {
                        self.writeToLog(s: "Error \(error.localizedDescription)")
                    }
                }
                
                group.notify(queue: DispatchQueue.global()) {
                    completion(eventsSend == eventSubArrayObjects.count)
                }
            }
        }
    }
    ///Stop the timer and save
    /// Save event to send or Ping hosts and send event attributes to the server
    /// - Parameter eventName: Event's name
    /// - Parameter journeyName:Test case's name
    /// - Parameter eventValue:Event's value
    /// - Parameter othersEventAttributes:Others attributed to add to event's attributes dictionnary
    internal func trackNewEvent(eventName: String, eventValue: String,journeyName: String,othersEventAttributes:[String:Any]? = nil)  {
        if self.checkEvent(eventName: eventName) && self.checkJourney(journeyName: journeyName)
        {
            self.synchroniseAttributesLocally(eventName: eventName, eventValue: eventValue, journeyName: journeyName,othersEventAttributes:othersEventAttributes)
            // if send realtime not supported we will wend our events stored when we will reach the batch siez defined
            if self.sendRealTimeEvents == false
            {
                if self.eventsData.count >= self.maxBatchSize
                {
                    self.sendAllEvents { success in }
                }
                else
                {
                    self.sendRemainingEventWork?.cancel()
                    self.sendRemainingEventWork = DispatchWorkItem(block: {
                        self.sendAllEvents { success in }
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(self.batchTimeout), execute: self.sendRemainingEventWork!)
                }
            }
        }
    }
    ///Get number of events to discard and add logs
    /// - Parameter maxCount The maximum number of events to synchronize
    /// - Parameter tempEventsData The list of events received and to synchronize
    ///  - Returns : New array following size adjustment
    internal func writeEventDiscarded(maxCount:Int,tempEventsData:[[String:Any]])->[[String:Any]]
    {
        var temporaryEventsData = tempEventsData.map { $0 }
        // update the total number of events captured
        self.eventCaptured = self.eventCaptured + tempEventsData.count
        if temporaryEventsData.count > maxCount {
            // just retrieve the first 50 events if the events array contains more than 50 events
            temporaryEventsData = Array(temporaryEventsData[0..<maxCount+1])
            self.writeToLog(s: "\(tempEventsData.count - maxCount) Event are not send due to limit")
            // update the total number of events Discarded
            self.eventDiscarded = self.eventDiscarded + (tempEventsData.count - maxCount)
            self.writeToLog(s: "Event discarded \(self.eventDiscarded)")
        }
        return temporaryEventsData
    }
    /// Get event attributes updated atfter set other data concerning the event
    /// - Parameter eventName event name
    /// - Parameter journeyName test case name
    /// - Parameter eventValue event value
    /// - Parameter othersEventAttributes others attributes to add to eventsAttributes
    /// - Returns  new eventDict after updated
    
    internal func getEventDictUpdated(eventName:String,journeyName: String, eventValue: String,othersEventAttributes:[String:Any]? = nil) -> [String:Any] {
        var eventAttributes = [String:Any]()
        if let othersEventAttributes = othersEventAttributes
        {
            for (key, value) in othersEventAttributes {
                eventAttributes[key] = value
            }
        }
        eventAttributes[MozarkAttributeKeys.dateTime.rawValue] = Date().convertToISOString()
        eventAttributes[MozarkAttributeKeys.testCaseName.rawValue] = journeyName
        eventAttributes[eventName] = eventValue
        return eventAttributes
    }
    /// Get joined attributes (all attributes to synchcronise) updated atfter set other data concerning the event
    /// - Parameter eventName event name
    /// - Parameter eventAttributes Dictionary contain all event attributes
    /// - Returns  new joinedDict after updated
    internal func getJoinedDictUpdated(eventName:String,eventAttributes:[String:Any]) -> [String:Any] {
        var joinAttributes = [String:Any]()
        joinAttributes[MozarkAttributeKeys.eventName.rawValue] = eventName
        joinAttributes[MozarkAttributeKeys.eventAttributes.rawValue] = eventAttributes
        return joinAttributes
    }
    /// Get Array of events to synchronize, It must be divisible by BatchSize
    /// - Parameter batchSize number of items per item
    /// - Parameter eventsArray array source
    /// - Returns Array of array divisible by BatchSize
    internal func getListEventsArrayToSynchronizeAccordingBatch(eventsArray: [[[String:Any]]], batchSize:Int)->[[[String:Any]]]
    {
        var resultEventArray : [[[String:Any]]] = [[[String:Any]]]()
        for eventArrayItem in eventsArray {
            if eventArrayItem.count == batchSize
            {
                resultEventArray.append(eventArrayItem)
            }
        }
        if resultEventArray.count == 0 && eventsArray.count > 0
        {
            resultEventArray.append(eventsArray.first!)
        }
        return resultEventArray
    }
    /// Get list of event names before send them to the serveur
    /// - Parameter eventsDict Dictionnary contain all events to send
    /// - Returns Array of event names
    internal func getEventNames(eventsDict:[[String:Any]])->[String] {
        var eventNamesArray :[String] = [String]()
        for eventDict in eventsDict {
            if let eventName = eventDict[MozarkAttributeKeys.eventName.rawValue] as? String
            {
                eventNamesArray.append(eventName)
            }
        }
        return eventNamesArray
    }
    /// Get Operator name
    /// - Returns operator name
    internal func getOperatorName()->String?
    {
        if let providers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders {
            if let provider = providers.values.first
            {
                return provider.carrierName
            }
        }
        return nil
    }
    ///Check if the event name in parameter exists in the list of event names defined in the constants sdk
    /// - Parameter eventName event name
    /// - Returns exist or  not
    
    internal func checkEvent(eventName:String)-> Bool
    {
        let mirror = Mirror(reflecting: EventConstants())
        let constants = mirror.children.compactMap { $0.value as? String }
        let checkEvent : Bool = constants.contains( eventName)
        if checkEvent == false
        {
            print("\u{26D4} Error : the event name '\(eventName)' not to be used for this app")
        }
        return checkEvent
    }
    ///Check if the journey name in parameter exists in the list of journey names defined in the constants sdk
    /// - Parameter journeyName journey name
    /// - Returns exist or  not
    internal func checkJourney(journeyName:String)-> Bool
    {
        let mirror = Mirror(reflecting: JourneyConstants())
        let constants = mirror.children.compactMap { $0.value as? String }
        let checkJourney : Bool = constants.contains( journeyName)
        if checkJourney == false
        {
            print("\u{26D4} Error : the journey name '\(journeyName)' not to be used for this app")
        }
        return checkJourney
    }
  
}
