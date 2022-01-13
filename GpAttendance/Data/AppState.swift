//
//  AppState.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import SwiftUI
import Combine

final class AppState: ObservableObject {
    private let watchConnector = WatchConnector.shared
    private var defaultStore = UserDefaultStore()
    private let cloudKitManager = CloudKitManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var arriveUrl: URL?
    @Published var leaveUrl: URL?
    @Published var isArrived: Bool = false
    @Published var arriveDate: Date?
    
    var isReachable: Bool {
        watchConnector.isReachable
    }
    
    init() {
        Task {
            do {
                try await fetchLatest()
            } catch {
                print("initialize error: \(error)")
            }
        }
        watchConnector.sendLatest = sendLatest
    }

    func fetchLatest() async throws {
        try await cloudKitManager.fetch()
        await MainActor.run {
            updateDataFromCloudKit()
        }
    }

    private func updateDataFromCloudKit() {
        if let entity = cloudKitManager.currentEntity {
            arriveUrl = entity.arriveUrl
            leaveUrl = entity.leaveUrl
            isArrived = entity.isArrived
            arriveDate = entity.arriveDate

            defaultStore.arriveUrl = entity.arriveUrl
            defaultStore.leaveUrl = entity.leaveUrl
            defaultStore.isArrived = entity.isArrived
            defaultStore.arriveDate = entity.arriveDate
        }
    }
    
    func setArriveUrl(_ url: URL?) {
        cloudKitManager.set(url?.absoluteString, forKey: .arriveUrl)
        defaultStore.arriveUrl = url
        arriveUrl = url
    }
    
    func setLeaveUrl(_ url: URL?) {
        cloudKitManager.set(url?.absoluteString, forKey: .leaveUrl)
        defaultStore.leaveUrl = url
        leaveUrl = url
    }
    
    func toggleArrived() {
        isArrived.toggle()
        defaultStore.isArrived = isArrived
        cloudKitManager.set(isArrived, forKey: .isArrived)
    }
    
    func setArriveDate(_ date: Date?) {
        cloudKitManager.set(date, forKey: .arriveDate)
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
