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
    @State private var reachable = "No"

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

                    if !appState.isReachable {
                        Button(action: {
                            reachable = "No"
                            appState.sendLatest()
                        }, label: {
                            Text("Fetch \(reachable)")
                        })
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
        .onAppear {
            if appState.isReachable {
                reachable = "Yes"
                appState.sendLatest()
            } else {
                reachable = "No"
            }
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(AppState())
    }
}
