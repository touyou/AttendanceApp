//
//  GpAttendanceApp.swift
//  GpAttendanceWatchApp Extension
//
//  Created by emp-mac-yosuke-fujii on 2021/08/20.
//

import SwiftUI
import CloudKit

@main
struct GpAttendanceApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) private var extensionDelegate

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any]) async -> WKBackgroundFetchResult {
        if CKNotification(fromRemoteNotificationDictionary: userInfo) != nil {
            NotificationCenter.default.post(name: CloudKitManager.ckUpdateNotification, object: nil)
            return .newData
        }
        return .noData
    }
}
