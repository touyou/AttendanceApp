//
//  SettingView.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject private var appState: AppState

    // MARK: State
    @State private var arriveUrlString = ""
    @State private var leaveUrlString = ""
    @State private var showingAlert = false

    // MARK: Environment
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("IFTTT URL")) {
                    HStack {
                        Text("出社用URL")
                        Spacer()
                        TextField("URLを入力してください。", text: $arriveUrlString)
                    }
                    HStack {
                        Text("退社用URL")
                        Spacer()
                        TextField("URLを入力してください。", text: $leaveUrlString)
                    }
                }
            }
        }
        .navigationBarTitle("Setting")
        .navigationBarItems(trailing: Button("保存") {
            appState.setArriveUrl(URL(string: arriveUrlString))
            appState.setLeaveUrl(URL(string: leaveUrlString))
            showingAlert = true
        })
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("保存しました"), dismissButton: .default(Text("OK"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
        .onAppear(perform: {
            arriveUrlString = appState.arriveUrl?.absoluteString ?? ""
            leaveUrlString = appState.leaveUrl?.absoluteString ?? ""
        })
        .onReceive(NotificationCenter.default.publisher(for: CloudKitManager.ckUpdateNotification)) { _ in
            Task {
                do {
                    try await appState.fetchLatest()
                    await MainActor.run {
                        arriveUrlString = appState.arriveUrl?.absoluteString ?? ""
                        leaveUrlString = appState.leaveUrl?.absoluteString ?? ""
                    }
                } catch {
                    print("fetch error: \(error)")
                }
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
