//
//  MozarkEvents+Location.swift
//  MozarkEventsSDK
//
//  Created by Mohamed Ali BELHADJ on 13/03/2023.
//

import Foundation
import CoreLocation
extension MozarkEvents : CLLocationManagerDelegate
{
    internal func checkAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied: break
        case .authorizedWhenInUse:
            fallthrough
        case .authorizedAlways:
            self.startUpdatingLocation()
        default:
            break
        }
    }
    internal func startUpdatingLocation() {
        let status = CLLocationManager.authorizationStatus()
        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }
        guard CLLocationManager.locationServicesEnabled() else { return }
        self.locationManager.startUpdatingLocation()
    }
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdatingLocation()
            default:
                print("Unauthorized")
            }
        }
        
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Get location with error : \(error.localizedDescription)")
    }
}
