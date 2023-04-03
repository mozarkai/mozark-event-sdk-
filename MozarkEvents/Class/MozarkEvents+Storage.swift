//
//  MozarkEvents+Storage.swift
//  SDK
//
//  Created by Mohamed Ali BELHADJ on 15/02/2023.
//

import Foundation
extension MozarkEvents
{
    
    /// Create Log file and save it in Documents Directory
    internal func createLogFile() {
        /// Get log file path
        guard let logFilePath = self.getLogFilePath(fileName: self.getLogFileName()) else { return }
        /// Create log file
        freopen(logFilePath.path.cString(using: String.Encoding.ascii), "a+", stderr)
    }
    /// Write text in the log file
    ///  - Parameter S:Text ou json string to save in the log file
    internal func writeToLog<T>(s:T) {
        guard let logFilePath = self.getLogFilePath(fileName: self.getLogFileName()) else { return }
        self.writeLogInFileAtPath(s: s, logFilePath: logFilePath)
    }
    /// Write text in the log file
    ///  - Parameter S:Text ou json string to save in the log file
    ///  - Parameter logFilePath:log file's path
    internal func writeLogInFileAtPath<T>(s:T,logFilePath:URL) {
        var dump = ""
        /// Check if file exist
        if FileManager.default.fileExists(atPath: logFilePath.path) {
            /// Get old log text
            dump =  try! String(contentsOfFile: logFilePath.path, encoding: .utf8)
        }
        do {
            /// Append new log text with old log text
            try  "\(dump)\n\(s)".write(toFile: logFilePath.path, atomically: true, encoding: .utf8)
        } catch let error {
            print("Failed writing to log file: \(logFilePath.path), Error: " + error.localizedDescription)
        }
    }
    /// Get log file's path
    ///  - Parameter fileName:File name based on event ID
    ///  - Returns  log file path
    internal func getLogFilePath(fileName:String)->URL?
    {
        guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        let logFilePath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(fileName)
        return logFilePath
    }
    /// Get file name based on event ID
    /// - Returns  file name
    internal func getLogFileName()->String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate =  formatter.string(from: Date())
        // Get event test id from json file
        var eventTestId = ""
        if let eventTestIdentifier =  self.testId
        {
            eventTestId = eventTestIdentifier
        }
        let fileName = "\(currentDate)_\(eventTestId).log"
        return fileName
    }
    /// Check if mozarkAttributes Json file exist in Documents directory and get its path
    /// - Returns json file path
    internal func mozarkAttributesPathExit() -> String?
    {
        guard let filePath = self.getMozarkJsonFilePath() else {return nil}
        guard FileManager.default.fileExists(atPath:filePath) else {
            return nil
        }
        return filePath
    }
    /// Check if mozarkAttributes Json file exist in Documents directory and get its path
    /// - Returns json file path
    internal func getMozarkJsonFilePath() -> String?
    {
        guard let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        let url = URL(fileURLWithPath: documentsDirectory)
        let pathComponent = url.appendingPathComponent(MozarkEventsConstants.Name.mozarkAttributesJsonFileName)
        return pathComponent.path
    }
    /// Copy mozarkAttributes Json file from ressources to Documents directory
    internal func copyMozarkJsonFileToDocumentsDirectory()
    {
        guard let jsonFilePath = self.getMozarkJsonFilePath() else {return}
        guard let sourceUrl = Bundle(for: type(of: self)).url(forResource: MozarkEventsConstants.Name.mozarkAttributesFileName, withExtension:"json") else {
            self.writeToLog(s: "Mozark json file not exist in ressources")
            return
        }
        if FileManager.default.fileExists(atPath:jsonFilePath)
        {
            do {
                try FileManager.default.removeItem(atPath: jsonFilePath)
            } catch {
                self.writeToLog(s: "Can't remove old json file")
            }
        }
        do {
            try FileManager.default.copyItem(atPath:  sourceUrl.path, toPath: jsonFilePath)
        } catch {
            self.writeToLog(s: "Can't remove copy new json file from ressouece to Documents app Folder")
        }
    }
    /// Copy mozarkAttributes Json file from ressources to Documents directory + Create log file
    internal func prepareEventsFileInDocumentsDirectory()
    {
        self.copyMozarkJsonFileToDocumentsDirectory()
        self.createLogFile()
        self.getEventCoordinates()
    }
}
