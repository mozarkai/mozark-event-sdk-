//
//  MozarkEvents+Network.swift
//  SDK
//
//  Created by Mohamed Ali BELHADJ on 15/02/2023.
//

import Foundation
import UIKit
extension MozarkEvents
{
    /// Get download speed and store value in userDefaults
    /// - Parameter completion:completion handler, called when we have an api response
    internal func updateDownloadSpeed(completion:@escaping (_ success:Bool) -> Void)  {
        let semaphore = DispatchSemaphore(value: 1)
        /// Launch Semaphore
        semaphore.wait()
        /// check link
        guard let url =  URL(string: MozarkEventsConstants.Link.speedLink) else{
            completion(false)
            return
        }
        /// Launch request
        let task =  URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, resp, error) in
            /// Check we have data returned
            guard error == nil && data != nil else{
                self.writeToLog(s: "connection error or data is nill")
                completion(false)
                return
            }
            guard resp != nil else{
                completion(false)
                self.writeToLog(s: "respons is nill")
                return
            }
            /// calculate speed test and store it in UserDefault
            let length  = CGFloat( (resp?.expectedContentLength)!) / 1000000.0
            let elapsed = CGFloat( Date().timeIntervalSince(Date()))
            let downloadSpeed = String(format: "%.2f", (length/elapsed))
            self.writeToLog(s: "length: \(length)")
            self.writeToLog(s: "elapsed: \(elapsed)")
            self.writeToLog(s: "Speed: \(length/elapsed) Mb/sec")
            self.writeToLog(s: "downloadSpeed:-\(downloadSpeed) MBps")
            UserDefaults.standard.set(downloadSpeed, forKey: "netspeed")
            completion(true)
            /// Finish semaphore
            semaphore.signal()
        }
        task.resume()
    }
    /// Get list of request with the hots to ping them
    ///  - Returns requests list
    internal func getRequestsArray() -> [URLRequest] {
        var requestsArray : [URLRequest] = [URLRequest]()
        for hostItem in MozarkEventsConstants.Link.hostArray {
            if let url = URL(string: MozarkEventsConstants.Link.hotStarBaseUrl + hostItem) {
                var request : URLRequest = URLRequest(url: url)
                request.httpMethod = "GET"
                requestsArray.append(request)
            }
        }
        return requestsArray
        
    }
    /// Ping hosts and send event with its attributes to the server
    /// - Parameter attributes:event's attributes
    /// - Parameter completion:completion handler, called when we have an send event api response
    internal  func pingHostsAndSendEventAttributesToServer(attributes:[String:Any],completion:@escaping (_ success:Bool) -> Void)  {
        
        self.updateDownloadSpeed { success in
            var hosts: [[String:Any]] = []
            var urlsPinged = 0
            var eventSend = false
            let group = DispatchGroup()
            guard let mozarkDictionary = self.mozarkAttributesDict else {
                self.writeToLog(s: "Mozark Json file not in JSON form")
                completion(false)
                return
            }
            //Get request's list based on hosts to ping them
            let requestsArray : [URLRequest] = self.getRequestsArray()
            for request in requestsArray {
                group.enter()
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let resultData = data
                    {
                        do {
                            // Get ping request response
                            let resultDict =  try JSONSerialization.jsonObject(with: resultData, options: []) as? [String: Any]
                            if let hostsDict = resultDict {
                                if let hostDict = self.getHostDict(request: request, resultDict: hostsDict)
                                {
                                    // Create Host Dict based on ping request response and add it in array
                                    hosts.append(hostDict)
                                }
                                else
                                {
                                    self.writeToLog(s: "error: response is not in JSON form")
                                }
                            }
                            else
                            {
                                self.writeToLog(s: "error: response is not in JSON form")
                            }
                            urlsPinged = urlsPinged + 1
                            
                            if request.url?.absoluteString == MozarkEventsConstants.Link.hotStarBaseUrl + MozarkEventsConstants.Link.hostArray.last!
                            {
                                // if we have finished traversing the array, we append the array of host dict to mozark attributes to send to server and we convert them to data
                                let jsonData = try JSONSerialization.data(withJSONObject: [self.updateMozarkAttributsDictForPingCase(attributes: attributes, mozarkDictionary: mozarkDictionary, hosts: hosts)], options: .prettyPrinted)
                                // Send data with event name 'Ping event'
                                self.sendEvent(encoded: jsonData, eventName: "Ping Event"){ success in
                                    eventSend = true
                                    DispatchQueue.global().async {
                                        group.leave()
                                    }
                                }
                                self.writeToLog(s: "Ping Event send")
                            }
                            else
                            {
                                DispatchQueue.global().async {
                                    group.leave()
                                }
                            }
                            
                        } catch {
                            self.writeToLog(s: "error: response is not in JSON form")
                        }
                    }
                    else
                    {
                        self.writeToLog(s: "error: response is not in JSON form")
                    }
                }.resume()
            }
            group.notify(queue: DispatchQueue.global()) {
                completion(urlsPinged == requestsArray.count && eventSend == true)
            }
        }
        
    }
    /// Send one event to the server
    ///  - Parameter encoded:Event's Data
    ///  - Parameter eventName:Event's name
    ///  - Parameter completion:completion handler, called when we have an send event api response
    internal func sendEvent(encoded:Data,eventName:String,completion:@escaping (_ success:Bool) -> Void){
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                guard let eventBaseUrl =  self.eventURL else{
                    print("eventURL is null !!!")
                    return
                }
                let eventUrl = eventBaseUrl + MozarkEventsConstants.Link.sendEventEndPoint
                guard let url =  URL(string: eventUrl) else{
                    return
                }
                self.writeToLog(s: "---Api Start here---")
                self.writeToLog(s: "---Event API url--- \(eventUrl)")
                self.writeToLog(s: "---Event encoded data--- \(eventUrl)")
                self.eventAPICalled += 1
                //Prepare the query
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.httpBody = encoded
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    // parse response and deal with errors
                    self.parseSendEventResponse(data: data, response: response, error: error, eventName: eventName)
                    completion(data != nil && error == nil )
                }
                task.resume()
            }
        }
    }
    /// Get download speed and store new value in userDefaults
    ///  - Returns Download speed value
    internal func getNetSpeed () ->String {
        if let speed = UserDefaults.standard.string(forKey: "netspeed")
        {
            writeToLog(s: "Get speed \(String(describing: speed))")
            writeToLog(s: self.speedBucket(speed: speed))
        }
        self.updateDownloadSpeed { success in
        }
        return ""
    }
    /// Get download speed by defining request timeout
    ///  - Parameter timeout:request timeout
    ///  - Parameter CompletionBlock:closure called when we have request's response
    
    internal func testDownloadSpeedWithTimeout(timeout: TimeInterval, withCompletionBlock: @escaping (_ megabytesPerSecond: Double? , _ error: Error?) -> Void) {
        guard let url = URL(string: MozarkEventsConstants.Link.speedLink) else { return }
        startTime = CFAbsoluteTimeGetCurrent()
        stopTime = startTime
        bytesReceived = 0
        speedTestCompletionBlock = withCompletionBlock
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = timeout
        URLSession.init(configuration: configuration, delegate: self, delegateQueue: nil).dataTask(with: url).resume()
    }
    /// Get speed interval
    ///  - Parameter speed:download speed
    ///  - Returns  speed interval
    internal func speedBucket (speed:String) ->String {
        guard let speedF = Float(speed) else { return "0"}
        switch speedF {
        case _ where speedF < 2.0:
            return "0 to 2"
        case 2..<4:
            return "2 to 4"
        case 4..<6:
            return "4 to 6"
        case 6..<8:
            return "6 to 8"
        case 8..<10:
            return "8 to 10"
        default:
            return ">10"
        }
    }
}
extension MozarkEvents:URLSessionDelegate, URLSessionDataDelegate
{
    /// URL session delegate methode used when we want get download speed with time out
    /// This callback called when request finished with success
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bytesReceived! += data.count
        stopTime = CFAbsoluteTimeGetCurrent()
    }
    /// This callback called when request finished with failure
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let startTime =  startTime,let stopTime = stopTime else{return}
        let elapsed = stopTime - startTime
        if let aTempError = error as NSError?, aTempError.domain != NSURLErrorDomain && aTempError.code != NSURLErrorTimedOut && elapsed == 0  {
            speedTestCompletionBlock?(nil, error)
            return
        }
        let speed = elapsed != 0 ? Double(bytesReceived ?? 0) / elapsed / 1024.0 / 1024.0 : -1
        speedTestCompletionBlock?(speed, nil)
    }
    
}
