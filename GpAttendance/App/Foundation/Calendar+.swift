//
//  Date+.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import Foundation

extension Calendar {
    static let shared: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        calendar.locale = .current
        return calendar
    }()

    func getDurationText(from startDate: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.shared
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = [.dropLeading]
        let timeInterval = Date().timeIntervalSince(startDate)
        return formatter.string(from: timeInterval)!
    }
}
