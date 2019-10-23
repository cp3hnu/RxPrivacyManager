//
//  PrivacyManager+Location.swift
//  PrivacyManager
//
//  Created by CP3 on 10/23/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

/// Location
public extension PrivacyManager {
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
            .catchErrorJustReturn(CLAuthorizationStatus.notDetermined)
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
    func requestLocation(always: Bool) {
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
}
