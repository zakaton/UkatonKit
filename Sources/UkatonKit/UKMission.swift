import Combine
import CoreBluetooth
import Foundation
import OSLog
import UkatonMacros

@StaticLogger
public class UKMission: ObservableObject {
    // MARK: - none type

    public static let none = UKMission(isNone: true)
    public private(set) var isNone: Bool = false
    private convenience init(isNone: Bool) {
        self.init()
        self.isNone = isNone
    }

    // MARK: - Initialization

    init() {}

    convenience init(discoveredBluetoothDevice: UKDiscoveredBluetoothDevice) {
        defer {
            self.name = discoveredBluetoothDevice.name
            self.deviceType = discoveredBluetoothDevice.type
            self.isConnectedToWifi = discoveredBluetoothDevice.isConnectedToWifi
            if self.isConnectedToWifi == true {
                self.ipAddress = discoveredBluetoothDevice.ipAddress
                self.shouldConnectToWifi = true
            }
            self.peripheral = discoveredBluetoothDevice.peripheral
        }

        self.init()
    }

    // MARK: - Connection

    var peripheral: CBPeripheral?

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
    @Published public private(set) var connectionStatus: UKConnectionStatus = .notConnected {
        didSet {
            if connectionStatus == .connected {
                UKMissionsManager.shared.add(self)
            }
            else if connectionStatus == .notConnected {
                UKMissionsManager.shared.remove(self)
            }
        }
    }

    public var isConnected: Bool {
        connectionStatus == .connected
    }

    // MARK: - Device Information

    @Published public internal(set) var name: String = "undefined"
    @Published public internal(set) var deviceType: UKDeviceType = .motionModule {
        didSet {
            let _self = self
            logger.debug("updated device type: \(_self.deviceType.name)")
            sensorData.deviceType = deviceType
        }
    }

    @Published public internal(set) var batteryLevel: UKBatteryLevel = .zero

    // MARK: - Wifi Information

    @Published public internal(set) var wifiSsid: String = ""
    @Published public internal(set) var wifiPassword: String = ""
    @Published public internal(set) var shouldConnectToWifi: Bool = false
    @Published public internal(set) var isConnectedToWifi: Bool = false {
        didSet {
            if !isConnectedToWifi {
                ipAddress = nil
                ipAddressSubject.send(nil)
            }
        }
    }

    @Published public internal(set) var ipAddress: String? = nil
    public let ipAddressSubject = PassthroughSubject<String?, Never>()

    // MARK: - Motion Calibration

    @Published public internal(set) var motionCalibration: UKMotionCalibration = .zero

    @Published public internal(set) var isFullyCalibrated: Bool = false

    // MARK: - Sensor Data Configurations

    @Published public internal(set) var sensorDataConfigurations: UKSensorDataConfigurations = .init()
    public let sensorDataConfigurationsSubject = PassthroughSubject<UKSensorDataConfigurations, Never>()
    var checkSensorDataTimer: Timer? = nil

    // MARK: - Sensor Data

    @Published public internal(set) var sensorData: UKSensorData = .init()
}

extension UKMission: Identifiable {
    public var id: String {
        connectionManager?.id ?? ""
    }
}

extension UKMission: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }

    public static func == (lhs: UKMission, rhs: UKMission) -> Bool {
        if lhs.isNone || rhs.isNone {
            return lhs.isNone && rhs.isNone
        }

        guard let lhsType = lhs.connectionType, let rhsType = lhs.connectionType, lhsType == rhsType else {
            return false
        }

        return !lhs.id.isEmpty && lhs.id == rhs.id
    }
}
