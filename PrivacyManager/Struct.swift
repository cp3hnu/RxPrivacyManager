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
    case contact
    case locationAlways
    case locationInUse
    case microphone
    case camera
    case photo
    case speech
    
    public var description: String {
        switch self {
        case .contact:         return "通讯录"
        case .locationAlways:   return "位置"
        case .locationInUse:    return "位置"
        case .microphone:       return "麦克风"
        case .camera:           return "相机"
        case .photo:           return "照片"
        case .speech:          return "语音识别"
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
