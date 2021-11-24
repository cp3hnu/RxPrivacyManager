//
//  LocationCtrlr.swift
//  PrivacyManagerDemo
//
//  Created by cp3hnu on 2021/11/15.
//  Copyright © 2021 CP3. All rights reserved.
//

import Foundation
import UIKit
import Bricking
import CoreLocation
import PrivacyManager
import PrivacyLocation
import RxSwift

final class LocationCtrlr: UIViewController {
   
    private let disposeBag = DisposeBag()
    private let statusLabel = UILabel()
    private let pointsLabel = UILabel()
    private let countLabel = UILabel()
    private var points = [CLLocation]() {
        didSet {
            countLabel.text = "\(points.count)"
            pointsLabel.text = points.reduce("", { result, location in
                return result + "\n" + "\(location.coordinate.longitude), \(location.coordinate.latitude)"
            })
        }
    }
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PrivacyManager.shared.locationManager.distanceFilter = kCLDistanceFilterNone
        PrivacyManager.shared.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        PrivacyManager.shared.locationManager.allowsBackgroundLocationUpdates = true
        PrivacyManager.shared.locationManager.showsBackgroundLocationIndicator = true
        
        title = "定位"
        view.backgroundColor = UIColor.white
        setupNaviBar()
        setupView()
        
        _ = PrivacyManager.shared.rxLocations
            .subscribe(
                onNext: { [weak self] locations in
                    if let first = locations.first {
                        self?.points.append(first)
                        var count = UserDefaults.standard.integer(forKey: "count") 
                        count += 1
                        UserDefaults.standard.set(count, forKey: "count")
                        UserDefaults.standard.synchronize()
                        self?.statusLabel.text = "\(count)"
                        
                    }
                }, onError: { error in
                    print("error", error)
                }, onCompleted: {
                    print("onCompleted")
                }, onDisposed: {
                    print("onDisposed")
                }
            ).disposed(by: disposeBag)
        
        PrivacyManager.shared.locationPermission(
            presenting: self,
            always: true,
            authorized: {
                //self?.statusLabel.text = "Status: " +  PrivacyManager.shared.locationStatus.description
            }, canceled: {
                // self?.statusLabel.text = "Status: " + PrivacyManager.shared.locationStatus.description
            }, setting: {
                //self?.statusLabel.text = "Status: " + PrivacyManager.shared.locationStatus.description
            })
        
        print(PrivacyManager.shared.locationManager.authorizationStatus.rawValue)
       
    }
    
    deinit {
        print("deinit")
    }
}

// MARK: - Setup
private extension LocationCtrlr {
    func setupNaviBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "清空", style: .plain, target: self, action: #selector(clear))
    }
    
    func setupView() {
        statusLabel.font = UIFont.systemFont(ofSize: 16)
        statusLabel.textColor = UIColor.black
        statusLabel.text = "\(UserDefaults.standard.integer(forKey: "count"))"
        
        countLabel.font = UIFont.systemFont(ofSize: 16)
        countLabel.textColor = UIColor.black
        countLabel.text = "0"
        
        pointsLabel.font = UIFont.systemFont(ofSize: 16)
        pointsLabel.numberOfLines = 0
        pointsLabel.backgroundColor = UIColor.red
        pointsLabel.textColor = UIColor.white
        view.asv(statusLabel, countLabel, pointsLabel)
        
        view.layoutInSafeArea(
            20,
            |-20-statusLabel,
            20,
            |-20-countLabel,
            20,
            |-20-pointsLabel-20-|,
            0
        )
        
        statusLabel.setContentHuggingPriority(.required, for: .vertical)
        countLabel.setContentHuggingPriority(.required, for: .vertical)
    }
    
    @objc func clear() {
        self.points = []
        UserDefaults.standard.set(0, forKey: "count")
        UserDefaults.standard.synchronize()
        statusLabel.text = "0"
    }
}

