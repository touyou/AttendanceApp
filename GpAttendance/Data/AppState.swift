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
        migrateAndInitialize()
        //        watchConnector.sendLatest = sendLatest
    }
    
    private func needMigration() -> Bool {
        if defaultStore.isMigrated {
            return false
        }
        
        if defaultStore.leaveUrl == nil && defaultStore.arriveDate == nil && defaultStore.arriveUrl == nil {
            return false
        }
        
        return true
    }
    
    func changeMigrationStatus(_ flag: Bool) {
        defaultStore.isMigrated = flag
    }
    
    func migrateAndInitialize() {
        if needMigration() {
            let entity = AppStateEntity(arriveUrl: defaultStore.arriveUrl, leaveUrl: defaultStore.leaveUrl, isArrived: defaultStore.isArrived, arriveDate: defaultStore.arriveDate)
            arriveUrl = defaultStore.arriveUrl
            leaveUrl = defaultStore.leaveUrl
            isArrived = defaultStore.isArrived
            arriveDate = defaultStore.arriveDate
            cloudKitManager.set(entity)
            defaultStore.isMigrated = true
        } else {
            cloudKitManager.fetch().receive(on: RunLoop.main).sink(receiveCompletion: { status in
                print("completed: \(status)")
            }, receiveValue: { [weak self] entity in
                guard let self = self else { return }
                self.arriveUrl = entity?.arriveUrl
                self.leaveUrl = entity?.leaveUrl
                self.isArrived = entity?.isArrived ?? false
                self.arriveDate = entity?.arriveDate
            }).store(in: &cancellables)
        }
    }
    
    func setArriveUrl(_ url: URL?) {
        cloudKitManager.set(url?.absoluteString, forKey: .arriveUrl)
        arriveUrl = url
    }
    
    func setLeaveUrl(_ url: URL?) {
        cloudKitManager.set(url?.absoluteString, forKey: .leaveUrl)
        leaveUrl = url
    }
    
    func toggleArrived() {
        isArrived.toggle()
        cloudKitManager.set(isArrived, forKey: .isArrived)
    }
    
    func setArriveDate(_ date: Date?) {
        cloudKitManager.set(date, forKey: .arriveDate)
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
