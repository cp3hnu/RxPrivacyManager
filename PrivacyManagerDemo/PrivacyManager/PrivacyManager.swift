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
                    forMediaType: AVMediaTypeVideo,
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
    
    /// 获取定位权限的状态(Always) - Driver
    public var rx_locationAlwaysPermission: Observable<PermissionStatus> {
        let status: Observable<PermissionStatus> = Observable.deferred { [weak locationManager, weak self] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            self?.requestLocation(always: true)
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
    
    /// 获取定位权限的状态(InUse) - Driver
    public var rx_locationInUsePermission: Observable<PermissionStatus> {
        let status: Observable<PermissionStatus> = Observable.deferred { [weak locationManager, weak self] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            self?.requestLocation(always: false)
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
