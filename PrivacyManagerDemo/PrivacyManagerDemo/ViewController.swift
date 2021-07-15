//
//  ViewController.swift
//  PrivacyManagerDemo
//
//  Created by CP3 on 17/4/13.
//  Copyright © 2017年 CP3. All rights reserved.
//

import UIKit
import RxSwift
import CoreLocation
import PrivacyManager
import PrivacyPhoto
import PrivacyCamera
import PrivacyMicrophone
import PrivacyContact
import PrivacyLocation
import PrivacySpeech

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - 获取状态
        let locationStatus = PrivacyManager.shared.locationStatus
        print("locationStatus = ", locationStatus)
        
        let cameraStatus = PrivacyManager.shared.cameraStatus
        print("cameraStatus = ", cameraStatus)
        
        let phoneStatus = PrivacyManager.shared.photoStatus
        print("phoneStatus = ", phoneStatus)
        
        let microphoneStatus = PrivacyManager.shared.microphoneStatus
        print("microphoneStatus = ", microphoneStatus)
        
        let contactStatus = PrivacyManager.shared.contactStatus
        print("contactStatus = ", contactStatus)
        
    
        _ = PrivacyManager.shared.rxLocations
            .skip(1)
            .subscribe(onNext: { locations in
            print("locations", locations)
        }, onError: { error in
            print("error", error)
        }, onCompleted: {
            print("onCompleted")
        }, onDisposed: {
            print("onDisposed")
        })
        
        // MARK: - UIViewController 请求权限 - 使用 UIViewcontroller 扩展方法 `privacyPermission`
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            PrivacyManager.shared.locationPermission(presenting: self, always: false, authorized: {
                self.present("定位服务已授权")
            })
        }
        
        view.backgroundColor = UIColor.white
        let button1 = UIButton()
        button1.setTitle("相机", for: .normal)
        button1.setTitleColor(UIColor.black, for: .normal)
        _ = button1.rx.tap.subscribe(
            onNext: { [weak self] _ in
                guard let self = self else { return }
                PrivacyManager.shared.cameraPermission(presenting: self, authorized: {
                    self.present("相机已授权")
                })
            }
        )
        
        let button2 = UIButton()
        button2.setTitle("照片", for: .normal)
        button2.setTitleColor(UIColor.black, for: .normal)
        _ = button2.rx.tap.subscribe(
            onNext: { [weak self] _ in
                guard let self = self else { return }
                PrivacyManager.shared.photoPermission(presenting: self, authorized: {
                    self.present("照片已授权")
                })
            }
        )
        
        
        let button3 = UIButton()
        button3.setTitle("麦克风", for: .normal)
        button3.setTitleColor(UIColor.black, for: .normal)
        _ = button3.rx.tap.subscribe(
            onNext: { [weak self] _ in
                guard let self = self else { return }
                
                PrivacyManager.shared.microphonePermission(presenting: self, authorized: {
                    self.present("麦克风已授权")
                })
            }
        )
        
        let button4 = UIButton()
        button4.setTitle("语音识别", for: .normal)
        button4.setTitleColor(UIColor.black, for: .normal)
        _ = button4.rx.tap.subscribe(
            onNext: { [weak self] _ in
                guard let self = self else { return }
                
                PrivacyManager.shared.speechPermission(presenting: self, authorized: {
                    self.present("语音识别已授权")
                })
            }
        )
        
    
        // MARK: - 使用 PrivacyManager 的 observable
        let button5 = UIButton()
        button5.setTitle("通讯录", for: .normal)
        button5.setTitleColor(UIColor.black, for: .normal)
        _ = button5.rx.tap
            .flatMap{ () -> Observable<Bool> in
                return PrivacyManager.shared.rxContactPermission
            }
            .subscribe(
                onNext: { [weak self] granted in
                    if !granted {
                        self?.presentPrivacySetting(type: PermissionType.contact)
                    } else {
                        self?.present("通讯录已授权")
                    }
                }
            )

        [button1, button2, button3, button4, button5].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[button]-15-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["button" : button]))
        }
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[button1(==40)]-40-[button2(==40)]-40-[button3(==40)]-40-[button4(==40)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["button1" : button1, "button2" : button2, "button3" : button3, "button4" : button4]))
        button5.topAnchor.constraint(equalTo: button4.bottomAnchor, constant: 40).isActive = true
        
    }
}

private extension ViewController {
    func present(_ content: String) {
        let alert = UIAlertController(title: content, message: "", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        alert.preferredAction = action
        
        present(alert, animated: true, completion: nil)
    }
}

