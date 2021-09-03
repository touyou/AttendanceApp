//
//  AppStateEntity.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/09/03.
//

import Foundation

struct AppStateEntity: Codable {
    let arriveUrl: URL?
    let leaveUrl: URL?
    let isArrived: Bool
    let arriveDate: Date?
}

extension AppStateEntity {
    func getData() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }

    static func decodeData(_ data: Data) -> AppStateEntity? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(AppStateEntity.self, from: data)
        } catch {
            return nil
        }
    }
}
