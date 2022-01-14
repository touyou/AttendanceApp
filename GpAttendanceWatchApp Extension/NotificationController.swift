//
//  NotificationController.swift
//  GpAttendanceWatchApp Extension
//
//  Created by emp-mac-yosuke-fujii on 2021/08/20.
//

import WatchKit
import SwiftUI
import UserNotifications
import CloudKit

class NotificationController: WKUserNotificationHostingController<NotificationView> {

    override var body: NotificationView {
        return NotificationView()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func didReceive(_ notification: UNNotification) {
    }
}
