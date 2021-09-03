//
//  PhoneConnector.swift
//  GpAttendanceWatchApp Extension
//
//  Created by emp-mac-yosuke-fujii on 2021/09/03.
//

import WatchConnectivity
import os.log

final class PhoneConnector: NSObject, ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Phone Connector")
    private var session: WCSession
    @Published private(set) var data: AppStateEntity?
    var isReachable: Bool {
        session.isReachable
    }

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
}

extension PhoneConnector: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            logger.debug("activated")
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

    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        logger.debug("did receive \(messageData)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.data = AppStateEntity.decodeData(messageData)
        }
        replyHandler(messageData)
    }
}
