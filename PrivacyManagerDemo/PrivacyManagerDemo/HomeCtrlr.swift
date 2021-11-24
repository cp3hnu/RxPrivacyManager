//
//  HomeCtrlr.swift
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
import Bricking

final class HomeCtrlr: UIViewController {
        
    private let tableView = UITableView()
    private let contents = [
        "Camera",
        "Photos",
        "Location",
        "Microphone",
        "Contacts",
        "Speech"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.title = "PrivacyManager"
        setupNaviBar()
        setupView()
    }
    
    func setupNaviBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refreshzPermission))
    }
    
    func setupView() {
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "privacyReuseId")
        tableView.rowHeight = 64
        tableView.separatorStyle = .singleLine
        view.asv(tableView)
        tableView.fillContainer()
    }
    
    @objc func refreshzPermission() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension HomeCtrlr: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "privacyReuseId", for: indexPath)
        var contentConfig = UIListContentConfiguration.valueCell()
        contentConfig.text = contents[indexPath.row]
        
        switch indexPath.row {
            case 0:
                contentConfig.secondaryText = PrivacyManager.shared.cameraStatus.description
            case 1:
                contentConfig.secondaryText = PrivacyManager.shared.photoStatus.description
            case 2:
                contentConfig.secondaryText = PrivacyManager.shared.locationStatus.description
            case 3:
                contentConfig.secondaryText = PrivacyManager.shared.microphoneStatus.description
            case 4:
                contentConfig.secondaryText = PrivacyManager.shared.contactStatus.description
            default:
                contentConfig.secondaryText = PrivacyManager.shared.speechStatus.description
        }
        
        cell.contentConfiguration = contentConfig
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
            case 0:
                PrivacyManager.shared.cameraPermission(presenting: self, authorized: { [weak self] in
                    self?.present("Camera Authorized")
                    self?.tableView.reloadData()
                }, canceled: { [weak self] in
                    self?.tableView.reloadData()
                }, setting: { [weak self] in
                    self?.tableView.reloadData()
                })
            case 1:
                PrivacyManager.shared.photoPermission(presenting: self, authorized: { [weak self] in
                    self?.present("Photos Authorized")
                    self?.tableView.reloadData()
                }, canceled: { [weak self] in
                    self?.tableView.reloadData()
                }, setting: { [weak self] in
                    self?.tableView.reloadData()
                })
            case 2:
                PrivacyManager.shared.locationPermission(presenting: self, always: true, authorized: { [weak self] in
                    self?.present("Location Authorized")
                    self?.tableView.reloadData()
                }, canceled: { [weak self] in
                    self?.tableView.reloadData()
                }, setting: { [weak self] in
                    self?.tableView.reloadData()
                })
//                let ctrlr = LocationCtrlr()
//                self.navigationController?.pushViewController(ctrlr, animated: true)
            case 3:
                PrivacyManager.shared.microphonePermission(presenting: self, authorized: { [weak self] in
                    self?.present("Microphone Authorized")
                    self?.tableView.reloadData()
                }, canceled: { [weak self] in
                    self?.tableView.reloadData()
                }, setting: { [weak self] in
                    self?.tableView.reloadData()
                })
            case 4:
                PrivacyManager.shared.contactPermission(presenting: self, authorized: { [weak self] in
                    self?.present("Contacts Authorized")
                    self?.tableView.reloadData()
                }, canceled: { [weak self] in
                    self?.tableView.reloadData()
                }, setting: { [weak self] in
                    self?.tableView.reloadData()
                })
            default:
                PrivacyManager.shared.speechPermission(presenting: self, authorized: { [weak self] in
                    self?.present("Speech Authorized")
                    self?.tableView.reloadData()
                }, canceled: { [weak self] in
                    self?.tableView.reloadData()
                }, setting: { [weak self] in
                    self?.tableView.reloadData()
                })
        }
    }
}

private extension HomeCtrlr {
    func present(_ content: String) {
        let alert = UIAlertController(title: content, message: "", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Sure", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        alert.preferredAction = action
        
        present(alert, animated: true, completion: nil)
    }
}

