import CoreBluetooth
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

    private var peripheral: CBPeripheral?

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

    @Published public private(set) var connectionType: UKConnectionType? = nil
    @Published public private(set) var connectionStatus: UKConnectionStatus = .notConnected

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

        guard connectionType.requiresWifi != true || isConnectedToWifi == true else {
            logger.error("connection type requires a wifi connection")
            return
        }

        if connectionStatus == .notConnected {
            disconnect()
        }

        var newConnectionManager: (any UKConnectionManager)? = nil
        switch connectionType {
        case .bluetooth:
            if let peripheral {
                newConnectionManager = UKBluetoothConnectionManager(peripheral: peripheral)
            }
            else {
                logger.error("no peripheral found")
            }
        case .udp:
            if let ipAddress {
                newConnectionManager = UKUdpConnectionManager(ipAddress: ipAddress)
            }
            else {
                logger.error("no ip address defined")
            }
        }

        if newConnectionManager != nil {
            logger.debug("switching to \(newConnectionManager!.type.name) connection")
            connectionManager = newConnectionManager
            connect()
        }
    }

    // MARK: - Wifi Information

    @Published public internal(set) var wifiSsid: String?
    @Published public internal(set) var wifiPassword: String?
    @Published public internal(set) var shouldConnectToWifi: Bool?
    @Published public internal(set) var isConnectedToWifi: Bool?
    @Published public internal(set) var ipAddress: String?

    // MARK: - Initialization

    init() {
        UKMissionsManager.shared.missions.append(self)
    }

    convenience init(discoveredBluetoothDevice: UKDiscoveredBluetoothDevice, connectionType: UKConnectionType) {
        defer {
            self.name = discoveredBluetoothDevice.name
            self.deviceType = discoveredBluetoothDevice.type
            self.isConnectedToWifi = discoveredBluetoothDevice.isConnectedToWifi
            if self.isConnectedToWifi == true {
                self.ipAddress = discoveredBluetoothDevice.ipAddress
                self.shouldConnectToWifi = true
            }
            self.peripheral = discoveredBluetoothDevice.peripheral

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
