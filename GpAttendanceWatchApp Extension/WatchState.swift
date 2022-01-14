//
//  WatchState.swift
//  GpAttendanceWatchApp Extension
//
//  Created by emp-mac-yosuke-fujii on 2022/01/14.
//

import SwiftUI
import Combine

final class WatchState: ObservableObject {
    private let cloudKitManager = CloudKitManager.shared

    @Published var arriveUrl: URL?
    @Published var leaveUrl: URL?
    @Published var isArrived: Bool = false
    @Published var arriveDate: Date?
    @Published var isLoading: Bool = false

    init() {
        isLoading = true
        Task {
            do {
                try await fetchLatest()
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                print("initialize error: \(error)")
            }
        }
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
        }
    }

    func toggleArrived() {
        isArrived.toggle()
        cloudKitManager.set(isArrived, forKey: .isArrived)
    }

    func setArriveDate(_ date: Date?) {
        cloudKitManager.set(date, forKey: .arriveDate)
        arriveDate = date
    }
}
