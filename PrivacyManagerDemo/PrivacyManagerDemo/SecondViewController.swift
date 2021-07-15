//
//  SecondViewController.swift
//  PrivacyManagerDemo
//
//  Created by cp3hnu on 2021/7/15.
//  Copyright © 2021 CP3. All rights reserved.
//

import UIKit
import PrivacyManager

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        title = "Second"
        
        print("-------------------------------")
        
        _ = PrivacyManager.shared.rxLocations
            .take(1)
            .subscribe(onNext: { locations in
            print("Second", locations)
        }, onError: { error in
            print("error", error)
        }, onCompleted: {
            print("onCompleted")
        }, onDisposed: {
            print("onDisposed")
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
