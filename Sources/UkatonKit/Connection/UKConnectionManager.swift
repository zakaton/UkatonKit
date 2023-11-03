import Foundation

protocol UKConnectionManager: Identifiable & Hashable {
    var id: String { get }
    var type: UKConnectionType { get }
    var status: UKConnectionStatus { get }

    var onStatusUpdated: ((UKConnectionStatus) -> Void)? { get set }

    var onMessageReceived: ((UKConnectionMessageType, Data, inout Data.Index) -> Void)? { get set }
    func sendMessage(type: UKConnectionMessageType, data: Data) throws

    static var allowedMessageTypes: [UKConnectionMessageType] { get }

    func connect()
    func disconnect()
}

extension UKConnectionManager {
    var allowedMessageTypes: [UKConnectionMessageType] { Self.allowedMessageTypes }
}

extension UKConnectionManager {
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: Self, rhs: Self) -> Bool {
        !lhs.id.isEmpty && lhs.id == rhs.id
    }
}
