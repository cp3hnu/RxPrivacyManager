//
//  PrivacyManager+Location.swift
//  PrivacyManager
//
//  Created by CP3 on 10/23/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import CoreLocation
import PrivacyManager

class LocationManager {
    static let shared = LocationManager()
    let locationManager: CLLocationManager
    
    init() {
       locationManager = CLLocationManager()
       locationManager.distanceFilter = 100
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
}

/// Location
public extension PrivacyManager {
    var locationManager: CLLocationManager {
        LocationManager.shared.locationManager
    }
    
    /// 获取定位访问权限的状态
    var locationStatus: PermissionStatus {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            return .unknown
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        case .denied:
            return .unauthorized
        case .restricted:
            return .disabled
        @unknown default:
            return .unknown
        }
    }
    
    /// 获取定位权限的状态
    func rxLocationPermission(always: Bool) -> Observable<PermissionStatus> {
        let status: Observable<PermissionStatus> = Observable.deferred {
            let status = CLLocationManager.authorizationStatus()
            self.requestLocation(always: always)
            return self.locationManager
                .rx
                .didChangeAuthorizationStatus
                .startWith(status)
            }
            .catchAndReturn(CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .notDetermined:
                    return PermissionStatus.unknown
                case .authorizedWhenInUse, .authorizedAlways:
                    return PermissionStatus.authorized
                default:
                    return PermissionStatus.unauthorized
                }
            }
            .distinctUntilChanged()
        
        return status
    }
    
    /// 获取位置
    var rxLocations: Observable<[CLLocation]> {
        return locationManager.rx.didUpdateLocations
    }
    
    /// 获取位置错误
    var rxLocationError: Observable<Error> {
        return locationManager.rx.didFailWithError
    }
    
    /// 请求定位访问权限
    private func requestLocation(always: Bool) {
        if always {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /// 更新位置
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    /// 停止更新位置
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Present alert view controller for location
    func locationPermission(presenting: UIViewController, always: Bool, desc: String? = nil, authorized authorizedAction: @escaping PrivacyClosure, canceled cancelAction: PrivacyClosure? = nil, setting settingAction: PrivacyClosure? = nil) {
        
        let observable: Observable<Bool> = rxLocationPermission(always: true)
            .filter{ $0 != .unknown }
            .map{ $0 == .authorized }
        let type: PermissionType = always ? .locationAlways : .locationInUse
        
        return privacyPermission(type: type, rxPersission: observable, desc: desc, presenting: presenting, authorized: authorizedAction, canceled: cancelAction, setting: settingAction)
    }
}
