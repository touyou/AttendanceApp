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
            Text("π εεδΌγγγγͺοΌδ»ζ₯γι εΌ΅γγοΌ")
            Spacer()
            Button("εΊη€Ύ π’") {
                URLSession.shared.dataTask(with: appState.arriveUrl!) { _, _, error  in
                    DispatchQueue.main.async {
                        if let error = error {
                            showingAlert = AlertItem(alert: Alert(title: Text("γ¨γ©γΌ"), message: Text(error.localizedDescription)))
                        } else {
                            appState.toggleArrived()
                            appState.setArriveDate(Date())
                            showingAlert = AlertItem(alert: Alert(title: Text("εΊη€ΎγγΎγγοΌγγ‘γ€γοΌ")))
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
