import Foundation

protocol UKConnectionManager {
    var type: UKConnectionType { get }
    var status: UKConnectionStatus { get }

    var onStatusUpdated: ((UKConnectionStatus) -> Void)? { get set }

    var onMessageReceived: ((UKConnectionMessageType, Data) -> Void)? { get set }
    func sendMessage(type: UKConnectionMessageType, data: Data) throws

    static var allowedMessageTypes: [UKConnectionMessageType] { get }

    func connect()
    func disconnect()
}

extension UKConnectionManager {
    var allowedMessageTypes: [UKConnectionMessageType] { Self.allowedMessageTypes }
}
