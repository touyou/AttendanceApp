//
//  ContentView.swift
//  GpAttendanceWatchApp Extension
//
//  Created by emp-mac-yosuke-fujii on 2021/08/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var phoneConnector = PhoneConnector()
    @State private var reachable = "No"
    @State var date = Date()
    @State var timer: Timer?

    var body: some View {
        VStack {
            if let isArrived = phoneConnector.data?.isArrived {
                if phoneConnector.data?.arriveUrl == nil ||
                    phoneConnector.data?.leaveUrl == nil {
                    Text("⚒ アプリでURLを設定してください")
                } else if isArrived {
                    Text("⏰ 現在の勤務時間: " + Calendar.shared.getDurationText(from: phoneConnector.data!.arriveDate!, to: date))
                } else {
                    Text("🏡 退勤中")
                }
            } else {
                Text("⚒ アプリを開いてください")
                Button(action: {
                    reachable = phoneConnector.isReachable ? "Yes" : "No"
                }, label: {
                    Text("Fetch \(reachable)")
                })
            }
        }
        .onAppear {
            reachable = phoneConnector.isReachable ? "Yes" : "No"
            self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                self.date = Date()
            }
        }
        .onDisappear {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
