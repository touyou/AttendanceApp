//
//  GpAttendanceApp.swift
//  GpAttendanceWatchApp Extension
//
//  Created by emp-mac-yosuke-fujii on 2021/08/20.
//

import SwiftUI

@main
struct GpAttendanceApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
