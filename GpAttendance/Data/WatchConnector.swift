//
//  WatchConnector.swift
//  GpAttendance
//
//  Created by emp-mac-yosuke-fujii on 2021/08/20.
//

import WatchConnectivity
import os.log

final class WatchConnector: NSObject {
    static let shared = WatchConnector()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Watch Connector")
    private var session: WCSession

    var isReachable: Bool {
        session.isReachable
    }
    var sendLatest: (()->Void)?

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
    }

    func sendMessage(_ messages: [String: Any]) {
        session.sendMessage(messages, replyHandler: { [weak self] reply in
            self?.logger.debug("\(reply)")
        }, errorHandler: { [weak self] error in
            self?.logger.error("\(error.localizedDescription)")
        })
    }

    func sendMessage(_ messageData: Data) {
        session.sendMessageData(messageData, replyHandler:  { [weak self] reply in
            self?.logger.debug("\(reply)")
        }, errorHandler: { [weak self] error in
            self?.logger.error("\(error.localizedDescription)")
        })
    }
}

extension WatchConnector: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            logger.debug("activated")
            sendLatest?()
        case .inactive:
            logger.debug("inactive")
        case .notActivated:
            logger.debug("not activated")
        @unknown default:
            fatalError("not supported")
        }
        if let error = error {
            logger.error("\(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        logger.debug("did receive \(message)")
    }
}
