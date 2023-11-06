import Combine
import Foundation
import Network
import OSLog
import UkatonMacros

@StaticLogger
class UKUdpConnectionManager: UKConnectionManager {
    // MARK: - UKConnectionManager

    var id: String { ipAddress }

    static let allowedMessageTypes: [UKConnectionMessageType] = UKConnectionMessageType.allCases.filter { !$0.name.contains("wifi") }

    var onStatusUpdated: ((UKConnectionStatus) -> Void)?
    var onMessageReceived: ((UKConnectionMessageType, Data, inout Data.Index) -> Void)?

    let type: UKConnectionType = .udp
    var status: UKConnectionStatus = .notConnected {
        didSet {
            if status != oldValue {
                onStatusUpdated?(status)
            }
        }
    }

    // MARK: - Connection

    func connect() {
        guard timer == nil else {
            logger.warning("timer already started")
            return
        }

        status = .connecting

        startTimer()
    }

    func disconnect() {
        stopTimer()
        status = .notConnected
    }

    // MARK: - PING

    var timer: Timer?

    func startTimer() {
        guard timer == nil else {
            logger.warning("timer is already running")
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ping), userInfo: nil, repeats: true)
        timer?.tolerance = 0.2
    }

    func stopTimer() {
        guard timer != nil else {
            logger.warning("no timer to stop")
            return
        }

        timer!.invalidate()
        timer = nil
    }

    @objc func ping() {
        sendUdpMessage(type: status == .connecting ? .batteryLevel : .ping)
    }

    // MARK: - UDP

    var connection: NWConnection!
    let ipAddress: String!
    static var queue: DispatchQueue = .global(qos: .userInteractive)
    var queue: DispatchQueue { Self.queue }
    private var cancellable: AnyCancellable?

    static let portNumber: NWEndpoint.Port.IntegerLiteralType = 9999
    static let port: NWEndpoint.Port = .init(integerLiteral: portNumber)
    var port: NWEndpoint.Port { Self.port }

    init(ipAddress: String) {
        self.ipAddress = ipAddress

        let host: NWEndpoint.Host = .init(stringLiteral: self.ipAddress)

        let _self = self
        logger.debug("host: \(host.debugDescription), port: \(_self.port.debugDescription)")

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

    func sendRawData(_ data: Data) {
        logger.debug("sending udp data [\(data.count) bytes]")
        connection.send(content: data, completion: NWConnection.SendCompletion.contentProcessed { [unowned self] NWError in
            guard NWError == nil else {
                print("udp error")
                self.logger.error("error sending data: \(NWError)")
                return
            }
            self.logger.debug("sent data")
        })
    }

    func sendUdpMessage(type udpMessageType: UKUdpMessageType, data: Data? = nil) {
        var messageData: Data = .init()
        if let data {
            messageData = data
            if udpMessageType.shouldIncludeDataSize {
                messageData.insert(UInt8(data.count), at: 0)
            }
        }
        messageData.insert(udpMessageType.rawValue, at: 0)

        logger.debug("sending udp message of type \(udpMessageType.name)")

        sendRawData(messageData)
    }

    func sendMessage(type messageType: UKConnectionMessageType, data: Data) {
        guard let udpMessageType: UKUdpMessageType = .init(connectionMessageType: messageType) else {
            return
        }
        sendUdpMessage(type: udpMessageType, data: data)
    }

    // MARK: - Receive Message

    func receiveUDP() {
        connection.receiveMessage { [unowned self] data, _, isComplete, _ in
            if isComplete {
                self.logger.debug("receive complete")
                if let data {
                    self.logger.debug("received \(data.count) bytes")
                    DispatchQueue.main.async { [self] in
                        onRawMessageReceived(data: data)
                    }
                } else {
                    self.logger.debug("nil data")
                }
            }
            self.receiveUDP()
        }
    }

    func onRawMessageReceived(data: Data) {
        if status == .connecting {
            status = .connected
        }

        var offset: Data.Index = 0

        while offset < data.count {
            let rawUdpMessageType: UInt8 = data.parse(at: &offset)
            guard let udpMessageType: UKUdpMessageType = .init(rawValue: rawUdpMessageType) else {
                logger.error("uncaught raw udp message type \(rawUdpMessageType)")
                break
            }

            guard let connectionMessageType = udpMessageType.connectionMessageType else {
                logger.error("uncaught connectionMessageType for udpMessageType \(udpMessageType.name)")
                break
            }

            guard onMessageReceived != nil else {
                logger.error("no onMessageReceived callback")
                break
            }

            if udpMessageType.includesDataSize {
                let size: UInt8 = data.parse(at: &offset)
                let subData = data.subdata(in: offset ..< offset + Int(size))
                onMessageReceived(type: connectionMessageType, data: subData)
                offset += Int(size)
            } else {
                onMessageReceived?(connectionMessageType, data, &offset)
            }
        }
    }
}
