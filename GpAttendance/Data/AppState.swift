//
//  AppState.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import SwiftUI

final class AppState: ObservableObject {
    private let watchConnector = WatchConnector.shared
    private var defaultStore = UserDefaultStore()

    @Published var arriveUrl: URL?
    @Published var leaveUrl: URL?
    @Published var isArrived: Bool = false
    @Published var arriveDate: Date?

    init() {
        arriveUrl = defaultStore.arriveUrl
        leaveUrl = defaultStore.leaveUrl
        isArrived = defaultStore.isArrived
        arriveDate = defaultStore.arriveDate
    }

    func setArriveUrl(_ url: URL?) {
        defaultStore.arriveUrl = url
        arriveUrl = url
        watchConnector.sendMessage(toDict())
    }

    func setLeaveUrl(_ url: URL?) {
        defaultStore.leaveUrl = url
        leaveUrl = url
        watchConnector.sendMessage(toDict())
    }

    func toggleArrived() {
        isArrived.toggle()
        defaultStore.isArrived = isArrived
        watchConnector.sendMessage(toDict())
    }

    func setArriveDate(_ date: Date?) {
        defaultStore.arriveDate = date
        arriveDate = date
        watchConnector.sendMessage(toDict())
    }

    func toDict() -> [String: Any] {
        return [
            "arriveUrl": arriveUrl ?? "",
            "leaveUrl": leaveUrl ?? "",
            "isArrived": isArrived,
            "arriveDate": arriveDate ?? ""
        ]
    }
}
