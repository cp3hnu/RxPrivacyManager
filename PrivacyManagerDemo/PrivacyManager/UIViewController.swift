//
//  UIViewController.swift
//  PrivacyManagerDemo
//
//  Created by CP3 on 2017/4/13.
//  Copyright © 2017年 CP3. All rights reserved.
//

import UIKit

public typealias PrivacyClosure = () -> Void

// MARK: - Help
public extension UIViewController {
    public func privacyUnauthorized(type: PermissionType, cancelBlock: PrivacyClosure? = nil, settingBlock: PrivacyClosure? = nil) {
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
        alert.preferredAction = settingAction
        
        present(alert, animated: true, completion: nil)
    }
}
