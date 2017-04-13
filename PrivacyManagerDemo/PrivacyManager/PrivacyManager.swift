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

public typealias PrivacyClosure = () -> Void

private func onMainThread(block: () -> Void) {
    dispatch_async(dispatch_get_main_queue(), block)
}

private let CLLocationZero = CLLocation(latitude: 0, longitude: 0)
public class PrivacyManager {
    public static let sharedInstance = PrivacyManager()
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let subject = BehaviorSubject<CLLocation>(value: CLLocationZero)
        self.locationSubject = subject
        _ = locationManager.rx_didUpdateLocations.subscribeNext { locations in
            subject.onNext(locations.last ?? CLLocationZero)
        }
        
        return locationManager
    }()
    
    private var locationSubject: BehaviorSubject<CLLocation>!
}

// MARK: - Camera
public extension PrivacyManager {
    /// 获取相机访问权限的状态
    public var cameraStatus: PermissionStatus {
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch status {
        case .Authorized:
            return .Authorized
        case .Restricted, .Denied:
            return .Unauthorized
        case .NotDetermined:
            return .Unknown
        }
    }
    
    /// 获取相机访问权限的状态 - Observable
    public var rx_cameraStatus: Observable<PermissionStatus> {
        return Observable.create{ observer -> Disposable in
            let status = self.cameraStatus
            observer.onNext(status)
            
            if status == PermissionStatus.Unknown {
                AVCaptureDevice.requestAccessForMediaType(
                    AVMediaTypeVideo,
                    completionHandler: { granted in
                        onMainThread {
                            if granted {
                                observer.onNext(PermissionStatus.Authorized)
                            } else {
                                observer.onNext(PermissionStatus.Unauthorized)
                            }
                            observer.onCompleted()
                        }
                    }
                )
            } else {
                observer.onCompleted()
            }
            
            return NopDisposable.instance
        }
    }
}

// MARK: - Picture
public extension PrivacyManager {
    /// 获取照片访问权限的状态
    public var photosStatus: PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .Authorized:
            return .Authorized
        case .Denied, .Restricted:
            return .Unauthorized
        case .NotDetermined:
            return .Unknown
        }
    }
    
    /// 获取照片访问权限的状态 - Observable
    public var rx_photosStatus: Observable<PermissionStatus> {
        return Observable.create{ observer -> Disposable in
            let status = self.photosStatus
            observer.onNext(status)
            
            if status == PermissionStatus.Unknown {
                PHPhotoLibrary.requestAuthorization { status in
                    onMainThread {
                        if status == .Authorized {
                            observer.onNext(PermissionStatus.Authorized)
                        } else {
                            observer.onNext(PermissionStatus.Unauthorized)
                        }
                        observer.onCompleted()
                    }
                }
            } else {
                observer.onCompleted()
            }
            
            return NopDisposable.instance
        }
    }
}

// MARK: - Location
public extension PrivacyManager {
    /// 获取定位访问权限的状态
    public var locationStatus: PermissionStatus {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            return .Authorized
        case .Denied, .Restricted:
            return .Unauthorized
        case .NotDetermined:
            return .Unknown
        }
    }
    
    /// 获取定位权限的状态 - Driver
    var rx_locationStatus: Driver<PermissionStatus> {
        let status: Driver<PermissionStatus> = Observable.deferred { [weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            return locationManager
                .rx_didChangeAuthorizationStatus
                .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.NotDetermined)
            .map {
                switch $0 {
                case .NotDetermined:
                    return PermissionStatus.Unknown
                case .AuthorizedWhenInUse, .AuthorizedAlways:
                    return PermissionStatus.Authorized
                default:
                    return PermissionStatus.Unauthorized
                }
        }
        
        return status
    }
    
    /// 请求定位访问权限
    func requestLocation(always: Bool = false) {
        if always {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /// 获取当前位置
    var rx_location: Observable<CLLocation> {
        get {
            return locationSubject.asObservable()
                .filter{ $0 != CLLocationZero }
                .map{ (location) -> CLLocation in
                    // map WGC-84 to DB-09 coordinator
                    let newLocation = JZLocationConverter.wgs84ToBd09(location.coordinate)
                    return CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
                }
        }
    }
}


// MARK: - Help
public extension UIViewController {
    func privacyUnauthorized(type: PermissionType, cancelBlock: PrivacyClosure? = nil, settingBlock: PrivacyClosure? = nil) {
        let appName = UIDevice.currentDevice().appName
        presentAlertController(title: "\"\(appName)\"没有获得\(type.description)的访问权限", message: "请允许\"\(appName)\"访问您的\(type.description)", cancelTitle: "取消", cancelAction: { _ in
            cancelBlock?()
            }, preferredTitle: "设置", preferredAction: { _ in
                settingBlock?()
                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.sharedApplication().openURL(settingsUrl)
        })
    }
}



