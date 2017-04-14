//
//  PrivacyManager.swift
//  hnup
//
//  Created by CP3 on 16/7/4.
//  Copyright © 2016年 DataYP. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import Photos
import CoreLocation
import RxSwift
import RxCocoa


private func onMainThread(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}

private let CLLocationZero = CLLocation(latitude: 0, longitude: 0)
open class PrivacyManager {
    open static let sharedInstance = PrivacyManager()
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        return locationManager
    }()
}

// MARK: - Camera
public extension PrivacyManager {
    /// 获取相机访问权限的状态
    public var cameraStatus: PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .authorized:
            return .authorized
        case .restricted, .denied:
            return .unauthorized
        case .notDetermined:
            return .unknown
        }
    }
    
    /// 获取相机访问权限的状态 - Observable
    public var rx_cameraStatus: Observable<PermissionStatus> {
        return Observable.create{ observer -> Disposable in
            let status = self.cameraStatus
            observer.onNext(status)
            
            if status == PermissionStatus.unknown {
                AVCaptureDevice.requestAccess(
                    forMediaType: AVMediaTypeVideo,
                    completionHandler: { granted in
                        onMainThread {
                            if granted {
                                observer.onNext(PermissionStatus.authorized)
                            } else {
                                observer.onNext(PermissionStatus.unauthorized)
                            }
                            observer.onCompleted()
                        }
                    }
                )
            } else {
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - Picture
public extension PrivacyManager {
    /// 获取照片访问权限的状态
    public var photosStatus: PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return .authorized
        case .denied, .restricted:
            return .unauthorized
        case .notDetermined:
            return .unknown
        }
    }
    
    /// 获取照片访问权限的状态 - Observable
    public var rx_photosStatus: Observable<PermissionStatus> {
        return Observable.create{ observer -> Disposable in
            let status = self.photosStatus
            observer.onNext(status)
            
            if status == PermissionStatus.unknown {
                PHPhotoLibrary.requestAuthorization { status in
                    onMainThread {
                        if status == .authorized {
                            observer.onNext(PermissionStatus.authorized)
                        } else {
                            observer.onNext(PermissionStatus.unauthorized)
                        }
                        observer.onCompleted()
                    }
                }
            } else {
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - Location
public extension PrivacyManager {
    /// 获取定位访问权限的状态
    public var locationStatus: PermissionStatus {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        case .denied, .restricted:
            return .unauthorized
        case .notDetermined:
            return .unknown
        }
    }
    
    /// 获取定位权限的状态 - Driver
    public var rx_locationStatus: Driver<PermissionStatus> {
        let status: Driver<PermissionStatus> = Observable.deferred { [weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            return locationManager
                .rx
                .didChangeAuthorizationStatus
                .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
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
        
        return status
    }
    
    /// 请求定位访问权限
    public func requestLocation(always: Bool = false) {
        if always {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /// 获取当前位置
    public var rx_location: Driver<CLLocationCoordinate2D> {
        return locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
            .map { $0.coordinate }
    }
}

public extension PrivacyManager {
    
}






