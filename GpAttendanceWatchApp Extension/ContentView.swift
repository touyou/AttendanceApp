//
//  ContentView.swift
//  GpAttendanceWatchApp Extension
//
//  Created by emp-mac-yosuke-fujii on 2021/08/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var watchState = WatchState()

    @State var date = Date()
    @State var timer: Timer?

    var body: some View {
        VStack {
            if watchState.isLoading {
                Text("⏳ 情報取得中...")
            } else if watchState.arriveUrl == nil || watchState.leaveUrl == nil {
                Text("⚒ アプリでURLを設定してください")
            } else if watchState.isArrived {
                Text("⏰ 現在の勤務時間: " + Calendar.shared.getDurationText(from: watchState.arriveDate!, to: date))
                Button("退社 🏠") {
                    URLSession.shared.dataTask(with: watchState.leaveUrl!) { _, _, error in
                        DispatchQueue.main.async {
                            if let _ = error {
                            } else {
                                watchState.toggleArrived()
                            }
                        }
                    }.resume()
                }
            } else {
                Text("🏡 退勤中")
                Button("出社 🏢") {
                    URLSession.shared.dataTask(with: watchState.arriveUrl!) { _, _, error  in
                        DispatchQueue.main.async {
                            if let _ = error {
                            } else {
                                watchState.toggleArrived()
                                watchState.setArriveDate(Date())
                            }
                        }
                    }.resume()
                }
            }
        }
        .onAppear {
            self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                self.date = Date()
            }
        }
        .onDisappear {
            self.timer?.invalidate()
            self.timer = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: CloudKitManager.ckUpdateNotification)) { _ in
            watchState.isLoading = true
            Task {
                do {
                    try await watchState.fetchLatest()
                    await MainActor.run {
                        watchState.isLoading = false
                    }
                } catch {
                    print("fetch error: \(error)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
