//
//  EventAttributes.swift
//  SDK
//
//  Created by Tadam Mahesh on 03/02/23.
//

import Foundation

public struct EventDefaultAttributes{
    public init() {}
    public var uuid: String =  UUID().uuidString.lowercased()
    public var testId: String =  UUID().uuidString.lowercased()
    public var testStartDateTime : String =  "default_test_start_time"
    public var testEndDateTime : String =  "default_test_end_time"
    public var testStatus: String =  "default_test_status_unknown"
    public var projectName: String =  "default_project_name"
    public var testScriptName: String =  "default_test_script_name"
    public var deviceMake: String =  "default_device_make"
    public var deviceModel: String =  "default_device_model"
    public var devicePlatform: String =  "default_device_platform"
    public var devicePlatformVersion: String =  "default_device_platform_version"
    public var deviceCity: String =  "default_device_city"
    public var deviceCountry: String =  "default_device_country"
    public var deviceLocation: String =  "default_device_location"
    public var userName: String =  "default_user_name"
    public var browserName: String =  "default_browser_name"
    public var browserVersion: String =  "default_browser_version"
    public var deviceNetworkType: String =  "default_device_network_type"
    public var deviceMobileOperator: String =  "default_device_mobile_operator"
    public var deviceMobileNetworkTechnology: String =  "default_device_mobile_network_technology"
    public var deviceCityFromGeocode: String =  "default_device_city_from_geo_code"
    public var deviceCityFromIsp: String =  "default_device_city_from_isp"
    public var deviceCellularNetworkId: String =  "default_device_cellular_network_id"
    public var additionalInfo1: String =  "default_additional_info_1"
    public var additionalInfo2: String =  "default_additional_info_2"
    public var additionalInfo3: String =  "default_additional_info_3"
    public var additionalInfo4: String =  "default_additional_info_4"
    public var additionalIinfo5: String =  "default_additional_info_5"
    public var testCaseName: String =  "default_test_case_name"
    public var deviceSerial: String =  "default_device_serial"
    public var testStartTime = "default_test_start_time"
    public var testEndTime = "default_test_end_time"
    public var applicationId = "default_application_package_name"
    public var applicationName = "default_application_name"
    public var applicationVersion = "default_application_package_version"
    public var scriptId: String =  "default_script_name"
    public var serialID: String =  "default_serial"
    public var downloadSpeed: String =  "default_download_speed"
    public var orderId: Int =  0
    public var eventUrl: String =  "default_event_url"
    public var uploadSpeed: String =  "default_upload_speed"
    public var downloadSpeedBucket: String =  "default_download_speed_bucket"
    public var userId: Int =  0
    public var uploadSpeedBucket: String =  "default_upload_speed_bucket"
    public var httpsApiResult =  [Any]()
    public var city: String =  "default_device_city"
    public var deviceId: String =  "default_device_serial"
    public var operatorr = "default_device_mobile_operator"

}

public struct TestStartTime{
    public var date: Int =  0
    public var hours: Int =  0
    public var seconds: Int =  0
    public var month: Int =  0
    public var timezoneOffset: Int =  0
    public var year: Int =  0
    public var minutes: Int =  0
    public var time: Int =  0
    public var day: Int =  0
    
    var asDictionary : [String:Any] {
       let mirror = Mirror(reflecting: self)
       let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
         guard let label = label else { return nil }
         return (label, value)
       }).compactMap { $0 })
       return dict
     }
}
public struct TestEndTime{
    public var date: Int =  0
    public var hours: Int =  0
    public var seconds: Int =  0
    public var month: Int =  0
    public var timezoneOffset: Int =  0
    public var year: Int =  0
    public var minutes: Int =  0
    public var time: Int =  0
    public var day: Int =  0
    
    var asDictionary : [String:Any] {
       let mirror = Mirror(reflecting: self)
       let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
         guard let label = label else { return nil }
         return (label, value)
       }).compactMap { $0 })
       return dict
     }
}


