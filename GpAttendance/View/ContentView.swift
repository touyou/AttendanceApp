//
//  ContentView.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import SwiftUI

struct ContentView: View {
    struct AlertItem: Identifiable {
        var id = UUID()
        var alert: Alert
    }

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

                if appState.arriveUrl == nil || appState.leaveUrl == nil {
                    VStack {
                        Spacer()
                        Text("🔧 URLを設定してね！")
                        Spacer()
                        NavigationLink(destination: SettingView()) {
                            Text("設定する")
                        }
                        Spacer()
                    }
                } else if appState.isArrived {
                    VStack {
                        Spacer()
                        Text("⏰ 現在の勤務時間: " + Calendar.shared.getDurationText(from: appState.arriveDate!))
                        Spacer()
                        Button("退社 🏠") {
                            URLSession.shared.dataTask(with: appState.leaveUrl!) { _, _, error in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        showingAlert = AlertItem(alert: Alert(title: Text("エラー"), message: Text(error.localizedDescription)))
                                    } else {
                                        appState.toggleArrived()
                                        showingAlert = AlertItem(alert: Alert(title: Text("退社しました！おつかれさま！")))
                                    }
                                }
                            }.resume()
                        }
                        .padding(.vertical, 16.0)
                        .padding(.horizontal, 32.0)
                        .background(Color("GpRed"))
                        .foregroundColor(.white)
                        .cornerRadius(16.0)
                        Spacer()
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("🚀 十分休めたかな？今日も頑張ろう！")
                        Spacer()
                        Button("出社 🏢") {
                            URLSession.shared.dataTask(with: appState.arriveUrl!) { _, _, error  in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        showingAlert = AlertItem(alert: Alert(title: Text("エラー"), message: Text(error.localizedDescription)))
                                    } else {
                                        appState.toggleArrived()
                                        appState.setArriveDate(Date())
                                        showingAlert = AlertItem(alert: Alert(title: Text("出社しました！ファイト！")))
                                    }
                                }
                            }.resume()
                        }
                        .padding(.vertical, 16.0)
                        .padding(.horizontal, 32.0)
                        .background(Color("GpBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(16.0)
                        Spacer()
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
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
