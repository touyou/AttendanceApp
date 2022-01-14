//
//  ContentView.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject private var appState: AppState
    
    // MARK: State
    @State private var showingSettingView = false
    @State private var showingAlert: AlertItem?
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(
                    destination: SettingView(), isActive: $showingSettingView) {
                        EmptyView()
                    }
                
                VStack {
                    if appState.arriveUrl == nil || appState.leaveUrl == nil {
                        ShouldSetURLView()
                    } else if appState.isArrived {
                        WorkingTimeView(showingAlert: $showingAlert)
                    } else {
                        HomeTimeView(showingAlert: $showingAlert)
                    }
                }
                
            }
            .navigationTitle("Gp勤怠管理")
            .navigationBarItems(trailing: Button(action: {
                showingSettingView = true
            }) {
                Image(systemName: "gearshape")
            })
            .alert(item: $showingAlert) { item in
                item.alert
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: CloudKitManager.ckUpdateNotification)) { _ in
            Task {
                do {
                    try await appState.fetchLatest()
                } catch {
                    print("fetch error: \(error)")
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(AppState())
    }
}
