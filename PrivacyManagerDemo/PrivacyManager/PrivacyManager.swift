//
//  PrivacyManager.swift
//  hnup
//
//  Created by CP3 on 16/7/4.
//  Copyright © 2016年 CP3. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import Photos
import CoreLocation
import Contacts
import RxSwift
import RxCocoa
import AddressBook

private func onMainThread(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async {
        closure()
    }
}

public class PrivacyManager {
    public static let shared = PrivacyManager()
    
    fileprivate lazy var locationManager: CLLocationManager = {
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
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .notDetermined:
            return .unknown
        case .authorized:
            return .authorized
        case .denied:
            return .unauthorized
        case .restricted:
            return .disabled
        }
    }
    
    /// 获取相机访问权限的状态 - Observable
    public var rx_cameraPermission: Observable<Bool> {
        return Observable.create{ observer -> Disposable in
            let status = self.cameraStatus
            switch status {
            case .unknown:
                AVCaptureDevice.requestAccess(
                    for: AVMediaType.video,
                    completionHandler: { granted in
                        onMainThread {
                            observer.onNext(granted)
                            observer.onCompleted()
                        }
                })
            case .authorized:
                observer.onNext(true)
                observer.onCompleted()
            default:
                observer.onNext(false)
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
        case .notDetermined:
            return .unknown
        case .authorized:
            return .authorized
        case .denied:
            return .unauthorized
        case .restricted:
            return .disabled
        }
    }
    
    /// 获取照片访问权限的状态 - Observable
    public var rx_photosPermission: Observable<Bool> {
        return Observable.create{ observer -> Disposable in
            let status = self.photosStatus
            switch status {
            case .unknown:
                PHPhotoLibrary.requestAuthorization { status in
                    onMainThread {
                        observer.onNext(status == .authorized)
                        observer.onCompleted()
                    }
                }
            case .authorized:
                observer.onNext(true)
                observer.onCompleted()
            default:
                observer.onNext(false)
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
        case .notDetermined:
            return .unknown
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        case .denied:
            return .unauthorized
        case .restricted:
            return .disabled
        }
    }
    
    /// 获取定位权限的状态
    public func rx_locationPermission(always: Bool) -> Observable<PermissionStatus> {
        let status: Observable<PermissionStatus> = Observable.deferred { [weak locationManager, weak self] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            self?.requestLocation(always: always)
            return locationManager
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
    public var rx_locations: Observable<[CLLocation]> {
        return locationManager.rx.didUpdateLocations
    }
    
    /// 获取位置错误
    public var rx_locationError: Observable<Error> {
        return locationManager.rx.didFailWithError
    }
    
    /// 请求定位访问权限
    public func requestLocation(always: Bool) {
        if always {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /// 更新位置
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    /// 停止更新位置
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - Microphone
public extension PrivacyManager {
    /// 获取麦克风访问权限的状态
    public var microphoneStatus: PermissionStatus {
        let status = AVAudioSession.sharedInstance().recordPermission()
        switch status {
        case AVAudioSessionRecordPermission.undetermined:
            return .unknown
        case AVAudioSessionRecordPermission.granted:
            return .authorized
        default:
            return .unauthorized
        }
    }
    
    /// 获取麦克风访问权限的状态 - Observable
    public var rx_microphonePermission: Observable<Bool> {
        return Observable.create{ observer -> Disposable in
            let status = self.microphoneStatus
            switch status {
            case .unknown:
                AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                    onMainThread {
                        observer.onNext(granted)
                        observer.onCompleted()
                    }
                })
            case .authorized:
                observer.onNext(true)
                observer.onCompleted()
            default:
                observer.onNext(false)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - Contact
public extension PrivacyManager {
    /// 获取通讯录访问权限的状态
    public var contactStatus: PermissionStatus {
        if #available(iOS 9.0, *) {
            let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
            switch status {
            case .notDetermined:
                return .unknown
            case .authorized:
                return .authorized
            case .denied:
                return .unauthorized
            case .restricted:
                return .disabled
            }
        } else {
            let status = ABAddressBookGetAuthorizationStatus()
            switch status {
            case .notDetermined:
                return .unknown
            case .authorized:
                return .authorized
            case .denied:
                return .unauthorized
            case .restricted:
                return .disabled
            }
        }
    }
    
    /// 获取通讯录访问权限的状态 - Observable
    public var rx_contactPermission: Observable<Bool> {
        return Observable.create{ observer -> Disposable in
            let status = self.contactStatus
            switch status {
            case .unknown:
                if #available(iOS 9.0, *) {
                    CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, error) in
                        onMainThread {
                            observer.onNext(granted)
                            observer.onCompleted()
                        }
                    })
                } else {
                    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
                    ABAddressBookRequestAccessWithCompletion(addressBookRef, { (granted, error) in
                        onMainThread {
                            observer.onNext(granted)
                            observer.onCompleted()
                        }
                    })
                }
            case .authorized:
                observer.onNext(true)
                observer.onCompleted()
            default:
                observer.onNext(false)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
