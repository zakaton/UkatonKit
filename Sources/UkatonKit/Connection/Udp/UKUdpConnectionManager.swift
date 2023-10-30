import Foundation
import Network
import OSLog
import UkatonMacros

@StaticLogger
class UKUdpConnectionManager: UKConnectionManager {
    static let allowedMessageTypes: [UKConnectionMessageType] = UKConnectionMessageType.allCases.filter { $0.name.contains("wifi") }

    var onStatusUpdated: ((UKConnectionStatus) -> Void)?

    let type: UKConnectionType = .udp
    var status: UKConnectionStatus = .notConnected {
        didSet {
            if status != oldValue {
                onStatusUpdated?(status)
            }
        }
    }

    func connect() {
        // TODO: - start interval
    }

    func disconnect() {
        // TODO: - stop interval
        status = .notConnected
    }

    // MARK: - UDP

    var listener: NWListener!
    var connection: NWConnection!
    var queue = DispatchQueue.global(qos: .userInitiated)

    convenience init(to host: String, on port: Int) {
        self.init(
            to: NWEndpoint.Host(stringLiteral: host),
            on: NWEndpoint.Port(integerLiteral: NWEndpoint.Port.IntegerLiteralType(port))
        )
    }

    init(to host: NWEndpoint.Host, on port: NWEndpoint.Port) {
        logger.debug("host: \(host.debugDescription), port: \(port.debugDescription)")

        connection = NWConnection(host: host, port: port, using: .udp)
        connection.stateUpdateHandler = { [unowned self] newState in
            logger.debug("new state: \(String(describing: newState))")
            switch newState {
            case .ready:
                self.receiveUDP()
            case .setup:
                break
            case .cancelled:
                break
            case .preparing:
                break
            default:
                logger.error("uncaught state \(String(describing: newState))")
            }
        }

        connection.start(queue: queue)
    }

    // MARK: - Send Message

    var onMessageReceived: ((UKConnectionMessageType, Data, inout Data.Index) -> Void)?

    func sendMessage(type messageType: UKConnectionMessageType, data: Data) {
        guard let udpMessageType: UKUdpMessageType = .init(connectionMessageType: messageType) else {
            return
        }

        var content: Data = .init(data)
        if udpMessageType.shouldIncludeDataSize {
            content.insert(UInt8(data.count), at: 0)
        }
        content.insert(udpMessageType.rawValue, at: 0)

        connection.send(content: content, completion: NWConnection.SendCompletion.contentProcessed { [unowned self] NWError in
            guard NWError == nil else {
                self.logger.error("error sending \(messageType.name) message: \(NWError)")
                return
            }
            self.logger.debug("sent \(messageType.name) message")
        })
    }

    // MARK: - Receive Message

    func receiveUDP() {
        connection.receiveMessage { [unowned self] data, _, isComplete, _ in
            if isComplete {
                self.logger.debug("receive complete")
                if let data {
                    onRawMessageReceived(data: data)
                }
                else {
                    self.logger.debug("nil data")
                }
            }
            self.receiveUDP()
        }
    }

    func onRawMessageReceived(data: Data) {
        var offset: Data.Index = 0

        while offset < data.count {
            let rawUdpMessageType: UInt8 = data.parse(at: &offset)
            guard let udpMessageType: UKUdpMessageType = .init(rawValue: rawUdpMessageType) else {
                logger.error("uncaught raw udp message type \(rawUdpMessageType)")
                break
            }

            // TODO: - how to properly parse?
            guard let connectionMessageType = udpMessageType.connectionMessageType else {
                logger.error("uncaught raw udp message type \(udpMessageType.name)")
                break
            }

            guard let onMessageReceived else {
                logger.error("no onMessageReceived callback")
                break
            }

            onMessageReceived(connectionMessageType, data, &offset)
        }
    }
}
