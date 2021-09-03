//
//  HomeTimeView.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/08/20.
//

import SwiftUI

struct HomeTimeView: View {
    @EnvironmentObject private var appState: AppState

    @Binding var showingAlert: AlertItem?

    var body: some View {
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
                            appState.sendLatest()
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

struct HomeTimeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTimeView(showingAlert: .constant(nil))
    }
}
