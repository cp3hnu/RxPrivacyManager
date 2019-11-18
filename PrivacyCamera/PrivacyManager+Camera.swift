//
//  PrivacyManager+Camera.swift
//  PrivacyManager
//
//  Created by CP3 on 10/23/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import AVFoundation
import PrivacyManager

/// Camera
public extension PrivacyManager {
    /// 获取相机访问权限的状态
    var cameraStatus: PermissionStatus {
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
        @unknown default:
            return .unknown
        }
    }
    
    /// 获取相机访问权限的状态 - Observable
    var rxCameraPermission: Observable<Bool> {
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
    
    /// Present alert view controller for camera
    func privacyCameraPermission(desc: String? = nil, presenting: UIViewController, authorized authorizedAction: @escaping PrivacyClosure, canceled cancelAction: PrivacyClosure? = nil, setting settingAction: PrivacyClosure? = nil) {
        return privacyPermission(type: PermissionType.camera, rxPersission: rxCameraPermission, desc: desc, presenting: presenting, authorized: authorizedAction, canceled: cancelAction, setting: settingAction)
    }
}
