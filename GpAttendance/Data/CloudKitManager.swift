//
//  CloudKitManager.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/09/03.
//

import CloudKit
import Combine

/// CloudKitに関する処理を行うマネージャクラス
final class CloudKitManager {
    static let shared = CloudKitManager()
    static let ckUpdateNotification = Notification.Name("cloudKitChanged")

    private let recordType = "Attendance"
    private let container = CKContainer(identifier: "iCloud.dev.touyou.GpAttendance")
    private lazy var database = container.privateCloudDatabase

    private var record: CKRecord?
    private var recordId: CKRecord.ID?

    var currentEntity: AppStateEntity? {
        if let record = record {
            return AppStateEntity.convert(record)
        } else {
            return nil
        }
    }

    enum Keys: String {
        case arriveUrl
        case leaveUrl
        case isArrived
        case arriveDate
    }

    init() {
        Task {
            let subscriptions = try await database.allSubscriptions()
            if subscriptions.isEmpty {
                registerNotification()
                recordId = CKRecord.ID(recordName: "GpAttendance")
            } else {
                do {
                    let (matchingResults, _) = try await database.records(matching: CKQuery(recordType: recordType, predicate: NSPredicate(value: true)))
                    let result = matchingResults.first
                    recordId = result?.0 ?? CKRecord.ID(recordName: "GpAttendance")
                    record = try result?.1.get()
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }

    /// 値を一個保存する
    func set(_ object: CKRecordValueProtocol?, forKey key: Keys) {
        if let record = record {
            record[key.rawValue] = object
        } else {
            recordId = CKRecord.ID(recordName: "GpAttendance")
            record = CKRecord(recordType: recordType, recordID: recordId!)
            record![key.rawValue] = object
        }
        database.modifyRecords(saving: record.flatMap { [$0] } ?? [], deleting: [], savePolicy: .changedKeys, atomically: true, completionHandler: { result in
            switch result {
            case .success(let value):
                print("Success update: \(value)")
            case .failure(let error):
                print("Failure update: \(error)")
            }
        })
    }

    /// AppStateEntityごとCloudKitに保存する
    func set(_ entity: AppStateEntity) {
        func setRecord(_ record: inout CKRecord) {
            record[Keys.arriveDate.rawValue] = entity.arriveUrl?.absoluteString
            record[Keys.leaveUrl.rawValue] = entity.leaveUrl?.absoluteString
            record[Keys.isArrived.rawValue] = entity.isArrived
            record[Keys.arriveDate.rawValue] = entity.arriveDate
        }
        if record == nil {
            recordId = CKRecord.ID(recordName: "GpAttendance")
            record = CKRecord(recordType: recordType, recordID: recordId!)
        }
        setRecord(&record!)
        database.modifyRecords(saving: record.flatMap { [$0] } ?? [], deleting: [], savePolicy: .changedKeys, atomically: true, completionHandler: { result in
            switch result {
            case .success(let value):
                print("Success update: \(value)")
            case .failure(let error):
                print("Failure update: \(error)")
            }
        })
    }

    func fetch() async throws {
        let (matchingResults, _) = try await database.records(matching: CKQuery(recordType: recordType, predicate: NSPredicate(value: true)))
        let result = matchingResults.first
        recordId = result?.0 ?? CKRecord.ID(recordName: "GpAttendance")
        record = try result?.1.get()
    }

    func registerNotification() {
        let subscription = CKQuerySubscription(recordType: recordType, predicate: NSPredicate(value: true), options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        subscription.notificationInfo = notification
        database.save(subscription) { subscription, error in
            if let error = error {
                print(error)
            } else if let subscription = subscription {
                print(subscription)
            } else {
                print("unknown")
            }
        }
    }
}

extension AppStateEntity {
    /// CKRecordをAppStateEntityに変換する
    static func convert(_ record: CKRecord) -> AppStateEntity {
        let arriveUrl = URL.create(by: record[CloudKitManager.Keys.arriveUrl.rawValue] as? String)
        let leaveUrl = URL.create(by: record[CloudKitManager.Keys.leaveUrl.rawValue] as? String)
        let isArrived = record[CloudKitManager.Keys.isArrived.rawValue] as? Bool
        let arriveDate = record[CloudKitManager.Keys.arriveDate.rawValue] as? Date

        return AppStateEntity(
            arriveUrl: arriveUrl,
            leaveUrl: leaveUrl,
            isArrived: isArrived ?? false,
            arriveDate: arriveDate
        )
    }
}

extension URL {
    /// Optional<String>をURLに変換する
    static func create(by string: String?) -> URL? {
        if let string = string {
            return URL(string: string)
        } else {
            return nil
        }
    }
}
