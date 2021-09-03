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

    var isReachable: Bool {
        watchConnector.isReachable
    }

    init() {
        arriveUrl = defaultStore.arriveUrl
        leaveUrl = defaultStore.leaveUrl
        isArrived = defaultStore.isArrived
        arriveDate = defaultStore.arriveDate
        watchConnector.sendLatest = sendLatest
    }

    func setArriveUrl(_ url: URL?) {
        defaultStore.arriveUrl = url
        arriveUrl = url
    }

    func setLeaveUrl(_ url: URL?) {
        defaultStore.leaveUrl = url
        leaveUrl = url
    }

    func toggleArrived() {
        isArrived.toggle()
        defaultStore.isArrived = isArrived
    }

    func setArriveDate(_ date: Date?) {
        defaultStore.arriveDate = date
        arriveDate = date
    }

    func sendLatest() {
        if let data = toData() {
            watchConnector.sendMessage(data)
        }
    }

    private func toDict() -> [String: Any] {
        return [
            "arriveUrl": arriveUrl ?? "",
            "leaveUrl": leaveUrl ?? "",
            "isArrived": isArrived,
            "arriveDate": arriveDate ?? ""
        ]
    }

    private func toData() -> Data? {
        let entity = AppStateEntity(arriveUrl: arriveUrl, leaveUrl: leaveUrl, isArrived: isArrived, arriveDate: arriveDate)
        return entity.getData()
    }
}
