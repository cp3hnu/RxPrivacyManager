//
//  Struct.swift
//  hnup
//
//  Created by CP3 on 16/7/4.
//  Copyright © 2016年 CP3. All rights reserved.
//

import Foundation

/// 类型
public enum PermissionType: Int, CustomStringConvertible {
    case contacts
    case locationAlways
    case locationInUse
    case microphone
    case camera
    case photos
    
    public var description: String {
        switch self {
        case .contacts:         return "通讯录"
        case .locationAlways:   return "位置"
        case .locationInUse:    return "位置"
        case .microphone:       return "麦克风"
        case .camera:           return "相机"
        case .photos:           return "照片"
        }
    }
}

/// 状态
public enum PermissionStatus: Int, CustomStringConvertible {
    case unknown
    case authorized
    case unauthorized
    case disabled
    
    public var description: String {
        switch self {
        case .unknown:      return "Unknown"
        case .authorized:   return "Authorized"
        case .unauthorized: return "Unauthorized"
        case .disabled:     return "Disabled" // System-level, Not Implementation
        }
    }
}
