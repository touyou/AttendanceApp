//
//  WorkingTimeView.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/08/20.
//

import SwiftUI

struct WorkingTimeView: View {
    @EnvironmentObject private var appState: AppState

    @Binding var showingAlert: AlertItem?
    @State var date: Date = Date()
    @State var timer: Timer?

    var body: some View {
        VStack {
            Spacer()
            Text("⏰ 現在の勤務時間: " + Calendar.shared.getDurationText(from: appState.arriveDate!, to: date))
            Spacer()
            Button("退社 🏠") {
                URLSession.shared.dataTask(with: appState.leaveUrl!) { _, _, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            showingAlert = AlertItem(alert: Alert(title: Text("エラー"), message: Text(error.localizedDescription)))
                        } else {
                            appState.toggleArrived()
                            appState.sendLatest()
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
        .onAppear {
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

struct WorkingTimeView_Previews: PreviewProvider {
    static var previews: some View {
        WorkingTimeView(showingAlert: .constant(nil))
    }
}
