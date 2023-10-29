import Foundation
import Network

class UKUdpConnectionManager: UKConnectionManager {
    static let allowedMessageTypes: [UKConnectionMessageType] = UKConnectionMessageType.allCases.filter { $0.name.contains("wifi") }

    var onStatusUpdated: ((UKConnectionStatus) -> Void)?

    func initializeDevice() {}

    let type: UKConnectionType = .udp
    var status: UKConnectionStatus = .notConnected

    // MARK: - Messaging

    var onMessageReceived: ((UKConnectionMessageType, Data) -> Void)?

    func sendMessage(type: UKConnectionMessageType, data: Data) {
        // TODO: - FILL
    }
}
