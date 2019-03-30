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
    public func presentPrivacySetting(type: PermissionType, desc: String? = nil, cancelBlock: PrivacyClosure? = nil, settingBlock: PrivacyClosure? = nil) {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
        let title = "\"\(appName)\"没有获得\(type.description)的访问权限"
        let message = desc ?? "请允许\"\(appName)\"访问您的\(type.description)，以便下一步操作。"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { _ in
             cancelBlock?()
        }
        let settingAction = UIAlertAction(title: "设置", style: UIAlertAction.Style.default) { _ in
            settingBlock?()
            let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.openURL(settingsUrl as URL)
        }
        alert.addAction(cancelAction)
        alert.addAction(settingAction)
        alert.preferredAction = settingAction
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Check Permission
extension UIViewController {
    public func privacyPermission(for type: PermissionType, desc: String? = nil, authorized authorizedAction: @escaping PrivacyClosure, canceled cancelAction: PrivacyClosure? = nil, setting settingAction: PrivacyClosure? = nil) {
        _  = observable(for: type)
            .takeUntil(rx.deallocated)
            .subscribe(
                onNext: { [weak self] result in
                    if result {
                        authorizedAction()
                    } else {
                        self?.presentPrivacySetting(type: PermissionType.camera, desc: desc, cancelBlock: cancelAction, settingBlock: settingAction)
                    }
                }
        )
    }
    
    private func observable(for type: PermissionType) -> Observable<Bool> {
        switch type {
        case PermissionType.camera:
            return PrivacyManager.shared.rxCameraPermission
        case PermissionType.photos:
            return PrivacyManager.shared.rxPhotosPermission
        case PermissionType.microphone:
            return PrivacyManager.shared.rxMicrophonePermission
        case PermissionType.contacts:
            return PrivacyManager.shared.rxContactPermission
        case PermissionType.locationAlways:
            return PrivacyManager.shared.rxLocationPermission(always: true)
                .filter{ $0 != .unknown }
                .map{ $0 == .authorized }
        case PermissionType.locationInUse:
            return PrivacyManager.shared.rxLocationPermission(always: false)
                .filter{ $0 != .unknown }
                .map{ $0 == .authorized }
        }
    }
}
