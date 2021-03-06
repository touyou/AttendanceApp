//
//  GpAttendanceWidget.swift
//  GpAttendanceWidget
//
//  Created by emp-mac-yosuke-fujii on 2021/07/02.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    var userDefaultStore = UserDefaultStore()

    func placeholder(in context: Context) -> AttendEntry {
        AttendEntry(date: Date(), isSetUrls: false, isArrived: false, arriveDate: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (AttendEntry) -> ()) {
        let entry = AttendEntry(date: Date(), isSetUrls: false, isArrived: false, arriveDate: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: date)!
        let entry = AttendEntry(date: date, isSetUrls: userDefaultStore.arriveUrl != nil && userDefaultStore.leaveUrl != nil, isArrived: userDefaultStore.isArrived, arriveDate: userDefaultStore.arriveDate)

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct AttendEntry: TimelineEntry {
    let date: Date
    let isSetUrls: Bool
    let isArrived: Bool
    let arriveDate: Date?
}

struct GpAttendanceWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if entry.isSetUrls {
            if entry.isArrived {
                VStack {
                    Text("ð¢ åºç¤¾ä¸­ã ãã")
                    Text(Calendar.shared.getDurationText(from: entry.arriveDate!, to: Date()))
                }
            } else {
                Text("ð  ãä¼ã¿ä¸­ã")
            }
        } else {
            Text("â ã¢ããªã§URLãè¨­å®ããã")
        }
    }
}

@main
struct GpAttendanceWidget: Widget {
    let kind: String = "GpAttendanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GpAttendanceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("GpAttendance Widget")
        .description("åºç¤¾ãããã©ãããè¨é²ãããï¼")
    }
}

struct GpAttendanceWidget_Previews: PreviewProvider {
    static var previews: some View {
        GpAttendanceWidgetEntryView(entry: AttendEntry(date: Date(), isSetUrls: false, isArrived: false, arriveDate: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
