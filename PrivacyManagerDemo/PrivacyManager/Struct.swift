//
//  Struct.swift
//  hnup
//
//  Created by CP3 on 16/7/4.
//  Copyright © 2016年 DataYP. All rights reserved.
//

import Foundation

/// 类型
public enum PermissionType: Int, CustomStringConvertible {
    case Contacts
    case LocationAlways
    case LocationInUse
    case Notifications
    case Microphone
    case Camera
    case Photos
    
    public var description: String {
        switch self {
        case .Contacts:         return "通讯录"
        case .LocationAlways:   return "位置"
        case .LocationInUse:    return "位置"
        case .Notifications:    return "通知"
        case .Microphone:       return "麦克风"
        case .Camera:           return "相机"
        case .Photos:           return "照片"
        }
    }
}

/// 状态
public enum PermissionStatus: Int, CustomStringConvertible {
    case Authorized
    case Unauthorized
    case Unknown
    case Disabled
    
    public var description: String {
        switch self {
        case .Authorized:   return "Authorized"
        case .Unauthorized: return "Unauthorized"
        case .Unknown:      return "Unknown"
        case .Disabled:     return "Disabled" // System-level
        }
    }
}