//
//  PrivacyManager.swift
//  hnup
//
//  Created by CP3 on 16/7/4.
//  Copyright © 2016年 CP3. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

public class PrivacyManager {
    public static let shared = PrivacyManager()
    private let disposeBag = DisposeBag()
    
    public func privacyPermission(type: PermissionType, rxPersission: Observable<Bool>, desc: String? = nil, presenting: UIViewController, authorized authorizedAction: @escaping PrivacyClosure, canceled cancelAction: PrivacyClosure? = nil, setting settingAction: PrivacyClosure? = nil) {
    rxPersission
        .subscribe(
            onNext: { result in
                if result {
                    authorizedAction()
                } else {
                    presenting.presentPrivacySetting(type: type, desc: desc, cancelBlock: cancelAction, settingBlock: settingAction)
                }
            }
        )
        .disposed(by: disposeBag)
    }
}
