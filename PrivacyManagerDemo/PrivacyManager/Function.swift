//
//  Function.swift
//  PrivacyManager
//
//  Created by CP3 on 10/23/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation

func onMainThread(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async {
        closure()
    }
}
