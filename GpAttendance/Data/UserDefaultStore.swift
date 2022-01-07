//
//  UserDefaultStore.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import Foundation

struct UserDefaultStore {
    @UserDefault("arriveUrl", default: nil) var arriveUrl: URL?
    @UserDefault("leaveUrl", default: nil) var leaveUrl: URL?
    @UserDefault("arrived", default: false) var isArrived: Bool
    @UserDefault("arriveDate", default: nil) var arriveDate: Date?
    @UserDefault("isMigrated", default: false) var isMigrated: Bool
}
