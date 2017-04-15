//
//  ViewController.swift
//  PrivacyManagerDemo
//
//  Created by CP3 on 17/4/13.
//  Copyright © 2017年 CP3. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PrivacyManager
import Stevia

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationStatus = PrivacyManager.sharedInstance.locationStatus
        print("locationStatus = ", locationStatus)
        
        let cameraStatus = PrivacyManager.sharedInstance.cameraStatus
        print("cameraStatus = ", cameraStatus)
        
        let phoneStatus = PrivacyManager.sharedInstance.photosStatus
        print("phoneStatus = ", phoneStatus)
        
        let microphoneStatus = PrivacyManager.sharedInstance.microphoneStatus
        print("microphoneStatus = ", microphoneStatus)
        
        let contactStatus = PrivacyManager.sharedInstance.contactStatus
        print("contactStatus = ", contactStatus)
        
        _ = PrivacyManager.sharedInstance.rx_locationPermission
            .delay(1, scheduler: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] status in
                    if status == .unauthorized {
                        self?.presentPrivacySetting(type: PermissionType.locationInUse)
                    } else if status == .authorized {
                        self?.present("定位服务已授权")
                    }
                }
            )
        PrivacyManager.sharedInstance.requestLocation(always: false)
        
        view.backgroundColor = UIColor.white
        let button1 = UIButton()
        button1.setTitle("相机", for: .normal)
        button1.setTitleColor(UIColor.black, for: .normal)
        _ = button1.rx.tap
            .flatMap{ () -> Observable<Bool> in
                return PrivacyManager.sharedInstance.rx_cameraPermission
            }
            .subscribe(
                onNext: { [weak self] granted in
                    if !granted {
                        self?.presentPrivacySetting(type: PermissionType.camera)
                    } else {
                        self?.present("相机已授权")
                    }
                }
            )
        
        let button2 = UIButton()
        button2.setTitle("照片", for: .normal)
        button2.setTitleColor(UIColor.black, for: .normal)
        _ = button2.rx.tap
            .flatMap{ () -> Observable<Bool> in
                return PrivacyManager.sharedInstance.rx_photosPermission
            }
            .subscribe(
                onNext: { [weak self] granted in
                    if !granted {
                        self?.presentPrivacySetting(type: PermissionType.photos)
                    } else {
                        self?.present("照片已授权")
                    }
                }
        )
        
        
        let button3 = UIButton()
        button3.setTitle("麦克风", for: .normal)
        button3.setTitleColor(UIColor.black, for: .normal)
        _ = button3.rx.tap
            .flatMap{ () -> Observable<Bool> in
                return PrivacyManager.sharedInstance.rx_microphonePermission
            }
            .subscribe(
                onNext: { [weak self] granted in
                    if !granted {
                        self?.presentPrivacySetting(type: PermissionType.microphone)
                    } else {
                        self?.present("麦克风已授权")
                    }
                }
        )
        
        let button4 = UIButton()
        button4.setTitle("通讯录", for: .normal)
        button4.setTitleColor(UIColor.black, for: .normal)
        _ = button4.rx.tap
            .flatMap{ () -> Observable<Bool> in
                return PrivacyManager.sharedInstance.rx_contactPermission
            }
            .subscribe(
                onNext: { [weak self] granted in
                    if !granted {
                        self?.presentPrivacySetting(type: PermissionType.contacts)
                    } else {
                        self?.present("通讯录已授权")
                    }
                }
            )

        
        view.sv(
            button1,
            button2,
            button3,
            button4
        )
        view.layout(
            80,
            |-15-button1-15-| ~ 40,
            40,
            |-15-button2-15-| ~ 40,
            40,
            |-15-button3-15-| ~ 40,
            40,
            |-15-button4-15-| ~ 40
        )
    }
}

private extension ViewController {
    func present(_ content: String) {
        let alert = UIAlertController(title: content, message: "", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        alert.preferredAction = action
        
        present(alert, animated: true, completion: nil)
    }
}

