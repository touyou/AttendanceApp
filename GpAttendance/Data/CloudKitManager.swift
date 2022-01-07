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
    
    private let recordId = CKRecord.ID(recordName: "GpAttendance")
    private let recordType = "Attendance"
    private let container = CKContainer.default()
    private lazy var database = container.privateCloudDatabase

    private var record: CKRecord?
    

    enum Keys: String {
        case arriveUrl
        case leaveUrl
        case isArrived
        case arriveDate
    }

    init() {
        database.fetch(withRecordID: recordId) { [weak self] (newRecord, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
            } else if let newRecord = newRecord {
                self.record = newRecord
            }
        }
    }

    /// 値を一個保存する
    func set(_ object: CKRecordValueProtocol?, forKey key: Keys) {
        if let record = record {
            record[key.rawValue] = object
        } else {
            record = CKRecord(recordType: recordType, recordID: recordId)
            record![key.rawValue] = object
        }
        database.save(record!) { record, error in
            print("saved record \(record) / error: \(error)")
        }
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
            record = CKRecord(recordType: recordType, recordID: recordId)
        }
        setRecord(&record!)
        database.save(record!) { record, error in
            print("saved record \(record) / error: \(error)")
        }
    }

    /// AppStateEntityの形でCloudKitから取り出す
    func fetch() -> Future<AppStateEntity?, Error> {
        Future<AppStateEntity?, Error> { [weak self] promise in
            guard let self = self else { return }
            self.database.fetch(withRecordID: self.recordId, completionHandler: { ckrecord, error in
                if let error = error {
                    promise(.failure(error))
                } else if let ckrecord = ckrecord {
                    promise(.success(AppStateEntity.convert(ckrecord)))
                } else {
                    promise(.success(nil))
                }
            })
        }
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
