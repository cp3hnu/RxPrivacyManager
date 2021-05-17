//
//  UIViewController.swift
//  PrivacyManagerDemo
//
//  Created by CP3 on 2017/4/13.
//  Copyright © 2017年 CP3. All rights reserved.
//

import UIKit

public typealias PrivacyClosure = () -> Void

// MARK: - Present Alert Controller
public extension UIViewController {
    func presentPrivacySetting(type: PermissionType, desc: String? = nil, cancelBlock: PrivacyClosure? = nil, settingBlock: PrivacyClosure? = nil) {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
        let title = "\"\(appName)\"没有获得\(type.description)的访问权限"
        let message = desc ?? "请允许\"\(appName)\"访问您的\(type.description)，以便下一步操作。"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { _ in
             cancelBlock?()
        }
        let settingAction = UIAlertAction(title: "设置", style: UIAlertAction.Style.default) { _ in
            settingBlock?()
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(settingAction)
        alert.preferredAction = settingAction
        
        present(alert, animated: true, completion: nil)
    }
}
