//
//  PrivacyManager+Contact.swift
//  PrivacyManager
//
//  Created by CP3 on 10/23/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Contacts
import PrivacyManager

/// Contact
public extension PrivacyManager {
    /// 获取通讯录访问权限的状态
    var contactStatus: PermissionStatus {
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
        @unknown default:
            return .unknown
        }
    }
    
    /// 获取通讯录访问权限的状态 - Observable
    var rxContactPermission: Observable<Bool> {
        return Observable.create{ observer -> Disposable in
            let status = self.contactStatus
            switch status {
            case .unknown:
                CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, error) in
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
    
    /// Present alert view controller for contact
    func privacyContactPermission(desc: String? = nil, presenting: UIViewController, authorized authorizedAction: @escaping PrivacyClosure, canceled cancelAction: PrivacyClosure? = nil, setting settingAction: PrivacyClosure? = nil) {
        return privacyPermission(type: PermissionType.contact, rxPersission: rxContactPermission, desc: desc, presenting: presenting, authorized: authorizedAction, canceled: cancelAction, setting: settingAction)
    }
}
