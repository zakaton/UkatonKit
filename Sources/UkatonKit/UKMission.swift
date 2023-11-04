import Foundation
import OSLog
import UkatonMacros

@StaticLogger
public class UKMission: ObservableObject {
    // MARK: - Components

    public var motionCalibrationData: UKMotionCalibrationDataManager = .init()
    public var sensorDataConfigurations: UKSensorDataConfigurationsManager = .init()
    public var sensorData: UKSensorDataManager = .init()

    // MARK: - Device Information

    @Published public internal(set) var name: String?
    @Published public internal(set) var deviceType: UKDeviceType? {
        didSet {
            sensorDataConfigurations.deviceType = deviceType
            sensorData.deviceType = deviceType
        }
    }

    @Published public internal(set) var batteryLevel: UKBatteryLevel?

    // MARK: - Connection

    var connectionManager: (any UKConnectionManager)? {
        willSet {
            if connectionManager != nil {
                connectionManager?.disconnect()
                connectionManager?.onMessageReceived = nil
                connectionType = nil
            }
        }
        didSet {
            if connectionManager != nil {
                connectionManager?.onMessageReceived = { [unowned self] type, data, offset in
                    self.onConnectionMessage(type: type, data: data, at: &offset)
                }
                connectionManager?.onStatusUpdated = { [unowned self] in
                    self.connectionStatus = $0
                }
                connectionType = connectionManager?.type
            }
        }
    }

    @Published public var connectionType: UKConnectionType? = nil
    @Published public var connectionStatus: UKConnectionStatus = .notConnected {
        didSet {
            if connectionStatus == .connected {
                // TODO: - FILL
            }
        }
    }

    public func connect() {
        guard connectionManager != nil else {
            logger.error("no connectionManager defined")
            return
        }
        connectionManager?.connect()
    }

    public func disconnect() {
        guard connectionManager != nil else {
            logger.error("no connectionManager defined")
            return
        }
        connectionManager?.disconnect()
    }

    public func changeConnection(type connectionType: UKConnectionType) {
        guard self.connectionType == connectionType else {
            logger.warning("already connected via \(connectionType.name)")
            return
        }

        // TODO: - check if connectionType requires wifi and is connected to wifi
        if connectionStatus == .notConnected {
            disconnect()
        }
        // TODO: - update connectionManager
        connect()
    }

    // MARK: - Wifi Information

    @Published public internal(set) var wifiSsid: String?
    @Published public internal(set) var wifiPassword: String?
    @Published public internal(set) var shouldConnectToWifi: Bool?
    @Published public internal(set) var isConnectedToWifi: Bool?
    @Published public internal(set) var ipAddress: String?

    // MARK: - Initialization

    init() {
        // TODO: - add eventlistener for deviceType update
        UKMissionsManager.shared.missions.append(self)
    }

    convenience init(discoveredBluetoothDevice: UKDiscoveredBluetoothDevice, connectionType: UKConnectionType) {
        defer {
            self.connectionManager = discoveredBluetoothDevice.createConnectionManager(type: connectionType)
        }
        self.init()
    }
}

extension UKMission: Identifiable {
    public var id: String {
        connectionManager?.id ?? ""
    }
}

extension UKMission: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    public static func == (lhs: UKMission, rhs: UKMission) -> Bool {
        guard let lhsType = lhs.connectionType, let rhsType = lhs.connectionType, lhsType == rhsType else {
            return false
        }

        return !lhs.id.isEmpty && lhs.id == rhs.id
    }
}
