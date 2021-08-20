//
//  GpAttendanceApp.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import SwiftUI
import WidgetKit

@main
struct GpAttendanceApp: App {
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(AppState())
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
