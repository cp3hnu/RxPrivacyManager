//
//  UIViewController.swift
//  PrivacyManagerDemo
//
//  Created by CP3 on 2017/4/13.
//  Copyright © 2017年 CP3. All rights reserved.
//

import UIKit
import RxSwift

public typealias PrivacyClosure = () -> Void

// MARK: - Present Alert Controller
extension UIViewController {
    public func presentPrivacySetting(type: PermissionType, cancelBlock: PrivacyClosure? = nil, settingBlock: PrivacyClosure? = nil) {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
        let alert = UIAlertController(title: "\"\(appName)\"没有获得\(type.description)的访问权限", message: "请允许\"\(appName)\"访问您的\(type.description)", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { _ in
             cancelBlock?()
        }
        let settingAction = UIAlertAction(title: "设置", style: UIAlertActionStyle.default) { _ in
            settingBlock?()
            let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(settingsUrl as URL)
        }
        alert.addAction(cancelAction)
        alert.addAction(settingAction)
        if #available(iOS 9.0, *) {
            alert.preferredAction = settingAction
        }
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Check Permission
extension UIViewController {
    public func privacyPermission(for type: PermissionType, authorized authorizedAction: @escaping PrivacyClosure, canceled cancelAction: PrivacyClosure? = nil, setting settingAction: PrivacyClosure? = nil) {
        _  = observable(for: type)
            .takeUntil(rx.deallocated)
            .subscribe(
                onNext: { [weak self] result in
                    if result {
                        authorizedAction()
                    } else {
                        self?.presentPrivacySetting(type: PermissionType.camera, cancelBlock: cancelAction, settingBlock: settingAction)
                    }
                }
        )
    }
    
    private func observable(for type: PermissionType) -> Observable<Bool> {
        switch type {
        case PermissionType.camera:
            return PrivacyManager.shared.rx_cameraPermission
        case PermissionType.photos:
            return PrivacyManager.shared.rx_photosPermission
        case PermissionType.microphone:
            return PrivacyManager.shared.rx_microphonePermission
        case PermissionType.contacts:
            return PrivacyManager.shared.rx_contactPermission
        case PermissionType.locationAlways:
            return PrivacyManager.shared.rx_locationPermission(always: true)
                .filter{ $0 != .unknown }
                .map{ $0 == .authorized }
        case PermissionType.locationInUse:
            return PrivacyManager.shared.rx_locationPermission(always: false)
                .filter{ $0 != .unknown }
                .map{ $0 == .authorized }
        }
    }
}
