//
//  PrivacyManager+Photo.swift
//  PrivacyManager
//
//  Created by CP3 on 10/23/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Photos
import PrivacyManager

/// Photo
public extension PrivacyManager {
    /// 获取照片访问权限的状态
    var photosStatus: PermissionStatus {
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
        @unknown default:
            return .unknown
        }
    }
    
    /// 获取照片访问权限的状态 - Observable
    var rxPhotosPermission: Observable<Bool> {
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
    
    /// Present alert view controller for photo
    func photoPermission(presenting: UIViewController, desc: String? = nil, authorized authorizedAction: @escaping PrivacyClosure, canceled cancelAction: PrivacyClosure? = nil, setting settingAction: PrivacyClosure? = nil) {
        return privacyPermission(type: PermissionType.photo, rxPersission: rxPhotosPermission, desc: desc, presenting: presenting, authorized: authorizedAction, canceled: cancelAction, setting: settingAction)
    }
}
