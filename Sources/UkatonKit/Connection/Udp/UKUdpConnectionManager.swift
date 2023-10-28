import Foundation
import Network

class UKUdpConnectionManager: UKConnectionManager {
    let type: UKConnectionType = .udp
    var status: UKConnectionStatus = .notConnected

    // MARK: - Messaging

    var onMessageReceived: ((UKConnectionMessageType, Data) -> Void)?

    func sendMessage(type: UKConnectionMessageType, data: Data) {
        // TODO: - FILL
    }
}
