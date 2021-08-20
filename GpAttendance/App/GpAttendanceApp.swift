//
//  GpAttendanceApp.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import SwiftUI

@main
struct GpAttendanceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(AppState())
        }
    }
}
