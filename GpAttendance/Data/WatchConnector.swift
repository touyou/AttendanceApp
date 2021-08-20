//
//  WatchConnector.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/08/20.
//

import WatchConnectivity

final class WatchConnector: NSObject {
    static let shared = WatchConnector()

    private var session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }

    func sendMessage(_ messages: [String: Any]) {
        session.sendMessage(messages, replyHandler: nil, errorHandler: nil)
    }
}

extension WatchConnector: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
}
