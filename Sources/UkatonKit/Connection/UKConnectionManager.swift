import Foundation

protocol UKConnectionManager {
    var type: UKConnectionType { get }
    var status: UKConnectionStatus { get }

    var onMessageReceived: ((UKConnectionMessageType, Data) -> Void)? { get set }
    func sendMessage(type: UKConnectionMessageType, data: Data)
}
