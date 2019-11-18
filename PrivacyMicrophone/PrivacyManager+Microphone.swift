//
//  PrivacyManager+Microphone.swift
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

/// Microphone
public extension PrivacyManager {
    /// 获取麦克风访问权限的状态
    var microphoneStatus: PermissionStatus {
        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case .undetermined:
            return .unknown
        case .granted:
            return .authorized
        default:
            return .unauthorized
        }
    }
    
    /// 获取麦克风访问权限的状态 - Observable
    var rxMicrophonePermission: Observable<Bool> {
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
    
    /// Present alert view controller for microphone
    func microphonePermission(presenting: UIViewController, desc: String? = nil, authorized authorizedAction: @escaping PrivacyClosure, canceled cancelAction: PrivacyClosure? = nil, setting settingAction: PrivacyClosure? = nil) {
        return privacyPermission(type: PermissionType.microphone, rxPersission: rxMicrophonePermission, desc: desc, presenting: presenting, authorized: authorizedAction, canceled: cancelAction, setting: settingAction)
    }
}
