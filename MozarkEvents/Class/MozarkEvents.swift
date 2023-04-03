//
//  Detection.swift
//  SDK
//
//  Created by Mozark on 28/07/21.
//

import Foundation
import UIKit
import MozarkEventConstants
import CoreLocation


public class MozarkEvents:NSObject{
    /// Send log in realtime or at the end of the event
    internal var sendRealTimeEvents: Bool = false
    /// Check if we send actuelly events
    internal var sendRealTimeEventsInProgress: Bool = false
    /// Timer used to send event in real time
    internal var eventTimer: Timer?
    /// Timer used to send the remaining events after a timeout
    internal var sendAllEventsTimer: Timer?
    /// The time spent in sec
    internal var timeValue = 0
    /// The number of events to send
    internal var eventCaptured: Int = 0
    /// The number of synchronized events
    internal var eventSent: Int = 0
    /// The number of unsynchronized events
    internal var eventDiscarded: Int = 0
    /// The number of events successfully called
    internal var eventResponse: Int = 0
    /// The number of events called
    internal var eventAPICalled: Int = 0
    /// Api speed test call start time
    internal var startTime: CFAbsoluteTime?
    /// api speed test call end time
    internal var stopTime: CFAbsoluteTime?
    /// Number of bytes received following the call to the speed test API
    internal var bytesReceived: Int?
    /// Callback used following the call to the speed test API
    internal typealias speedTestCompletionHandler = (_ megabytesPerSecond: Double? , _ error: Error?) -> Void
    internal var speedTestCompletionBlock : speedTestCompletionHandler?
    /// Used to send remaining events not synchronized
    var sendRemainingEventWork : DispatchWorkItem?
    /// Contain the first events to synchronize, before the filter
    internal var mainEventData = [[String:Any]]()
    /// Used to stores events to skip
    internal var skipEventData = [[String:Any]]()
    /// Used to temporarily stores events to be synchronized
    internal var tempEventData = [[String:Any]]()
    /// Device identifier
    internal let deviceUdid : String? = {
        return UIDevice.current.identifierForVendor?.uuidString
    }()
    internal let locationManager = CLLocationManager()
    internal var currentLocation : CLLocation? = nil
    /// An object that contains all the attributes of an event to be synchronized with default values
    public var defaultEventAttribute = EventDefaultAttributes()
    /// All events data
    public var eventsData = [[String:Any]]()
    /// The app name
    public var applicationName: String? = nil
    /// The app bundle id
    public var applicationId: String? = nil
    /// The app version
    public var applicationVersion: String? = nil
    /// The base url to use to synchronize the logs
    public var eventURL: String? = nil
    /// The test identifier
    public var testId: String? = nil
    /// This objects contain all event names to use
    public var eventConstants : EventConstants = EventConstants()
    /// This objects contain all journey names to use
    public var journeyConstants : JourneyConstants = JourneyConstants()
    /// This dictionary contain mozark json data
    public var mozarkAttributesDict : [String:Any]?
    public var maxBatchSize : Int = 20
    public var batchTimeout : Int = 60

    /// Init MozarkEvents object and launch first event+ start timer
    ///
    /// - Parameter eventURL:The base url to use to synchronize the logs
    /// - Parameter sendRealTimeEvents:send log in realtime or at the end of the event
    /// - Parameter applicationName:the app name
    /// - Parameter applicationId:the app bundle id
    /// - Parameter applicationVersion:the app version
    public init(sendRealTimeEvents: Bool = false, eventURL: String? = nil, applicationName: String? = nil, applicationId: String? = nil,applicationVersion: String? = nil,maxBatchSize:Int = 20,batchTimeout : Int = 60) {
        super.init()
        /// Init Event attributs
        ///
        self.initilizeMozarkEventsFramework(sendRealTimeEvents: sendRealTimeEvents,maxBatchSize:maxBatchSize,batchTimeout:batchTimeout)
        self.sendRealTimeEvents = sendRealTimeEvents
        if let appName = applicationName
        {
            self.applicationName = appName
        }
        if let appId = applicationId
        {
            self.applicationId = appId
        }
        if let appVersion = applicationVersion
        {
            self.applicationVersion = appVersion
        }
        if let url = eventURL
        {
            self.eventURL = url
        }
    }
    /// Save event to send without value
    /// - Parameter eventName: Event's name
    /// - Parameter journeyName:Test case's name
    /// - Parameter eventValue:Event's value
    /// - Parameter othersEventAttributes:Others attributed to add to event's attributes dictionnary
    public func trackEvent(eventName: String,journeyName:String,othersEventAttributes:[String:Any]? = nil)
    {
        self.trackNewEvent(eventName: eventName, eventValue: "", journeyName: journeyName,othersEventAttributes: othersEventAttributes)
    }
    /// Save event to send with value
    /// - Parameter eventName: Event's name
    /// - Parameter journeyName:Test case's name
    /// - Parameter eventValue:Event's value
    /// - Parameter othersEventAttributes:Others attributed to add to event's attributes dictionnary
    public func trackMetric(eventName: String,eventValue:String,journeyName:String,othersEventAttributes:[String:Any]? = nil)
    {
        self.trackNewEvent(eventName: eventName, eventValue: eventValue, journeyName: journeyName,othersEventAttributes: othersEventAttributes)
    }
    /// Ping hosts and send event attributes to the server
    /// - Parameter eventName: Event's name
    /// - Parameter pingTestSuccess:Test sucess message
    /// - Parameter othersEventAttributes:Others attributed to add to event's attributes dictionnary
    /// - Parameter othersJoinAttributes:Others attributed to add to join attributes dictionnary
    public func trackPingEvent(eventName : String, pingTestSuccess: String,othersEventAttributes:[String:Any]? = nil,othersJoinAttributes:[String:Any]? = nil,completion:@escaping (_ success:Bool) -> Void)
    {
        var eventAttributes = [String:Any]()
        var joinAttributes = [String:Any]()
        if let othersEventAttributes = othersEventAttributes
        {
            for (key, value) in othersEventAttributes {
                eventAttributes[key] = value
            }
        }
        eventAttributes[MozarkAttributeKeys.dateTime.rawValue] = Date().convertToISOString()
        eventAttributes[MozarkAttributeKeys.pingServer.rawValue] = pingTestSuccess
        if let othersAttributes = othersJoinAttributes
        {
            for (key, value) in othersAttributes {
                joinAttributes[key] = value
            }
        }
        joinAttributes[MozarkAttributeKeys.eventName.rawValue] = eventName
        joinAttributes[MozarkAttributeKeys.eventAttributes.rawValue] = eventAttributes
        self.pingHostsAndSendEventAttributesToServer(attributes: joinAttributes){success in
            completion(success)
        }
    }
    /// Send all event
    /// - Parameter completion:completion handler, called when all events are sychnronized
    public func sendAllEvents(completion:@escaping (_ success:Bool) -> Void) {
        
        self.sendRemainingEventWork?.cancel()
        // reset counters
        self.eventAPICalled = 0
        self.eventResponse = 0
        var eventsSend = 0
        let group = DispatchGroup()
        self.eventCaptured = self.eventCaptured + self.eventsData.count + self.skipEventData.count
        // check loader and  skips events  data
        let evObjects = self.getListEventsArrayToSynchronizeAccordingBatch(eventsArray: self.eventsData.slice(size: self.maxBatchSize), batchSize: self.maxBatchSize)
        self.writeToLog(s: "evObjects count \(evObjects.count) === [\(evObjects)]")
        if evObjects.count > 0 {
            ///Browse events and send them one by one
            for (_, objects) in evObjects.enumerated() {
                group.enter()
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: objects, options: .prettyPrinted)
                    self.writeToLog(s: "==== check all events data === \(objects)")
                    self.writeToLog(s: "---isValidJson---\(jsonData.isValidJsonData(data: jsonData))")
                    self.sendEvent(encoded: jsonData, eventName: "All events") { success in
                        self.eventSent = self.eventSent + objects.count
                        eventsSend = eventsSend + 1
                        DispatchQueue.global().async {
                            group.leave()
                        }
                    }
                } catch {
                    self.writeToLog(s: "Error \(error.localizedDescription)")
                }
            }
            
            group.notify(queue: DispatchQueue.global()) {
                DispatchQueue.global().async(flags: .barrier) { [weak self] in
                    guard let self = self else { return }
                    var numberOfItemToRemove = 0
                    if evObjects.count > 1
                    {
                        numberOfItemToRemove = (evObjects.count*self.maxBatchSize)-1
                    }
                    else
                    {
                        if evObjects.count > 0
                        {
                            numberOfItemToRemove = evObjects.first!.count - 1
                        }
                    }
                    if self.eventsData.count > numberOfItemToRemove
                    {
                        self.eventsData.removeSubrange(0...numberOfItemToRemove)
                    }
                    if self.eventsData.count == 0
                    {
                        completion(eventsSend == evObjects.count)
                    }
                }
                
            }
        }
    }
    
    /// Send events with eventName = "sendEventsHard"
    /// - Parameter completion:completion handler, called when events are sychnronized
    public func sendEventsHard(completion:@escaping (_ success:Bool) -> Void){
        self.sendAllEventsTimer?.invalidate()
        self.sendAllEventsTimer = nil
        //To handle end event loop
        self.eventAPICalled = 0
        self.eventResponse = 0
        // Send at most 10 item
        let maxObjectToSend = self.writeEventDiscarded(maxCount: 10, tempEventsData: self.eventsData)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: maxObjectToSend, options: .prettyPrinted)
            // Convert events dictionnary to Data + and send them to the server
            self.sendEvent(encoded: jsonData, eventName: "sendEventsHard"){ success in
                self.writeToLog(s: "jsonData: \(jsonData)")
                self.eventSent = self.eventSent + maxObjectToSend.count
                self.writeToLog(s: "eventSent \(self.eventSent)")
                completion(success)
            }
        } catch {
            self.writeToLog(s: "Error \(error.localizedDescription)")
        }
        DispatchQueue.global().async(flags: .barrier) {
            //clean up
            self.eventsData.removeAll()
        }
    }
    /// Get contents of mozark json file
    /// - Returns dictionary which contain mozark json data
    public func getMozarkEventsDataFromJsonEmbeddedFile()->[String:Any]?{
        if let filePath = self.mozarkAttributesPathExit()
        {
            do {
                //Get Data from json file
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                do {
                    //Convert Data to Dictionary
                    let dataDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    guard let mozarkDictionary = dataDict else {
                        return nil
                    }
                    return mozarkDictionary
                }
                catch let error {print(error)}
            }
            catch { print(error)}
        }
        return nil
    }
    /// Send remaining rvents before test finished
    public func sendRemainingEvents(completion:@escaping (_ success:Bool) -> Void) {
        
        if self.sendRealTimeEvents == false
        {
            self.sendAllEvents { success in
                completion(success)
            }
        }
        else
        {
            self.sendEventsRealtime { success in
                completion(success)
            }
        }
    }
    /// Add start new journey event
    public func starNewJourney()
    {
        /// Add Start Event
        self.synchroniseAttributesLocally(eventName: self.eventConstants.startEventTrue, eventValue: "", journeyName: self.journeyConstants.start)
    }
    /// Add end journey event and send remaining events before test finished
    public func endJourneyAndSendItsRemainingEvents(completion:@escaping (_ success:Bool) -> Void)
    {
        /// Add end Event
        self.synchroniseAttributesLocally(eventName: self.eventConstants.endEventTrue, eventValue: "", journeyName: self.journeyConstants.end)
        self.sendRemainingEvents { success in
            completion(success)
        }
    }
    ///Stop the timer and save logs on the number of synchronized events
    public func endSendEvents() {
        // stop timer
        self.stopEventTimer()
        self.eventDiscarded = self.skipEventData.count
        //write logs
        if let deviceUdid = self.deviceUdid
        {
            writeToLog(s: "Device \(deviceUdid)")
        }
        writeToLog(s: "----Event Capture Log ----- ")
        writeToLog(s: "** Events Captured = \(eventCaptured), Total Events Sent = \(eventSent), Discarded Events = \(eventDiscarded) **")
        writeToLog(s: "----Event Capture End ----- ")
    }
    
}
