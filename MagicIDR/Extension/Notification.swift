//
//  Notification.swift
//  MagicIDR
//
//  Created by 박재우 on 2/27/24.
//

import Foundation

extension Notification.Name {
    static let isMuted = Notification.Name("IsMuted")
    static let isAutoCapture = Notification.Name("IsAutoCapture")
}

enum NotificationKey {
    case isMuted
    case isAutoCapture
}
