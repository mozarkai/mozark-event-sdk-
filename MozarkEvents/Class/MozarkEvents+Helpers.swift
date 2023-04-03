//
//  MozarkEvents+Helpers.swift
//  SDK
//
//  Created by Mohamed Ali BELHADJ on 14/02/2023.
//

import Foundation

extension Array {
    /// Convert an array into arrays of size items
    ///  - Parameter size:Number of elements to get per array
    func slice(size: Int) -> [[Element]] {
        (0...(count / size)).map{Array(self[($0 * size)..<(Swift.min($0 * size + size, count))])}
    }
}
extension Bundle {
    /// Get app version number
    var releaseVersionNumber: String? {
        return infoDictionary?[MozarkEventsConstants.Name.shortVersionKey] as? String
    }
    /// Get app build number
    var buildVersionNumber: String? {
        return infoDictionary?[MozarkEventsConstants.Name.versionKey] as? String
    }
}
extension Formatter {
    /// Get Date iso8601 with this format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    static let iso8601withFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }
    /// Convert Date iso8601 with this format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX" to string
    ///  - Returns string with specified format
    func convertToISOString()-> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter.string(from: self)
    }
    /// Get Timestamp
    ///  - Returns current timestamp
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970)
    }
}
extension String {
    /// Convert string to Date iso8601 with this format : "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    var iso8601withFractionalSeconds: Date? { return Formatter.iso8601withFractionalSeconds.date(from: self) }
}
extension Data {
    /// Check if we can parse data
    ///  - Parameter data:Data to parse
    func isValidJsonData(data:Data) -> Bool
    {
        do{
            let dataObj = try JSONSerialization.jsonObject(with: self, options: [])
            return dataObj is [AnyHashable:Any] || dataObj is Array<Any>
        }
        catch {
            return false
        }
    }
}

