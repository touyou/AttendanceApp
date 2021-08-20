//
//  ShouldSetURLView.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/08/20.
//

import SwiftUI

struct ShouldSetURLView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("🔧 URLを設定してね！")
            Spacer()
            NavigationLink(destination: SettingView()) {
                Text("設定する")
            }
            Spacer()
        }
    }
}

struct ShouldSetURLView_Previews: PreviewProvider {
    static var previews: some View {
        ShouldSetURLView()
    }
}
