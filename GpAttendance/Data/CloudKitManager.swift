//
//  CloudKitManager.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/09/03.
//

import CloudKit
import Combine

final class CloudKitManager {
    static let shared = CloudKitManager()

    private let recordId = CKRecord.ID(recordName: "GpAttendance")
    private let container = CKContainer.default()
    private lazy var database = container.privateCloudDatabase

    private var record: CKRecord?

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

    func set(_ object: CKRecordValueProtocol, forKey key: String) {
        if let record = record {
            record[key] = object
        } else {
            record = CKRecord(recordType: "Attendance", recordID: recordId)
            record![key] = object
        }
        database.save(record!) { _, _ in
            print("saved")
        }
    }

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
}

extension AppStateEntity {
    static func convert(_ record: CKRecord) -> AppStateEntity {
        let arriveUrl = URL.create(by: record["arriveUrl"] as? String)
        let leaveUrl = URL.create(by: record["leaveUrl"] as? String)
        let isArrived = record["isArrived"] as? Bool
        let arriveDate = record["arriveDate"] as? Date

        return AppStateEntity(
            arriveUrl: arriveUrl,
            leaveUrl: leaveUrl,
            isArrived: isArrived ?? false,
            arriveDate: arriveDate
        )
    }
}

extension URL {
    static func create(by string: String?) -> URL? {
        if let string = string {
            return URL(string: string)
        } else {
            return nil
        }
    }
}
