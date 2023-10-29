import Foundation
import OSLog
import UkatonMacros

@StaticLogger
public class UKMission: ObservableObject {
    // MARK: - Components

    var batteryLevelManager: UKBatteryLevelManager = .init()
    var deviceInformationManager: UKDeviceInformationManager = .init()
    var wifiInformationManager: UKWifiInformationManager = .init()
    var motionCalibrationDataManager: UKMotionCalibrationDataManager = .init()
    var sensorDataConfigurationsManager: UKSensorDataConfigurationsManager = .init()
    var sensorDataManager: UKSensorDataManager = .init()
    var hapticsManager: UKHapticsManager = .init()

    // MARK: - Connected

    @Published public var isConnected: Bool = false

    // MARK: - Connection

    var connectionManager: UKConnectionManager? {
        willSet {
            if var connectionManager {
                connectionManager.onMessageReceived = nil
                connectionType = nil
            }
        }
        didSet {
            if var connectionManager {
                connectionManager.onMessageReceived = { [unowned self] type, data in
                    self.onConnectionMessage(type: type, data: data)
                }
                connectionManager.onStatusUpdated = { [unowned self] in
                    self.connectionStatus = $0
                }
                connectionType = connectionManager.type
            }
        }
    }

    @Published public var connectionType: UKConnectionType? = nil
    @Published public var connectionStatus: UKConnectionStatus = .notConnected

    func sendMessage(type messageType: UKConnectionMessageType, data: Data) throws {
        guard let connectionManager else {
            throw UKConnectionManagerMessageError.noConnectionManager
        }
        guard connectionManager.status == .connected else {
            throw UKConnectionManagerMessageError.notConnected
        }

        guard connectionManager.allowedMessageTypes.contains(messageType) else {
            throw UKConnectionManagerMessageError.messageTypeNotImplemented(messageType)
        }

        try connectionManager.sendMessage(type: messageType, data: data)
    }

    // MARK: - Device Information

    @Published public private(set) var deviceType: UKDeviceType? {
        didSet {
            sensorDataConfigurationsManager.deviceType = deviceType
            sensorDataManager.deviceType = deviceType
        }
    }

    @Published public private(set) var deviceName: String?

    @Published public private(set) var isFullyInitialized: Bool = false {
        didSet {
            if isFullyInitialized {
                logger.debug("Fully initialized!")
                isConnected = true
            }
        }
    }

    @Published public private(set) var batteryLevel: UKBatteryLevel?

    public func setDeviceType(newDeviceType: UKDeviceType) async throws {
        try sendMessage(type: .setDeviceType, data: newDeviceType.rawValue.data)
        // TODO: - wait for deviceType event
    }

    public func setDeviceName(newDeviceName: String) async throws {
        try sendMessage(type: .setDeviceName, data: newDeviceName.data)
        // TODO: - wait for deviceType event
    }

    // MARK: - Motion Calibration

    public private(set) var isMotionSensorFullyCalibrated: Bool = false {
        didSet {
            if isMotionSensorFullyCalibrated {
                logger.debug("Motion Sensor is fully calibrated!")
            }
        }
    }

    // MARK: - Wifi Information

    @Published public private(set) var wifiSsid: String?
    @Published public private(set) var wifiPassword: String?

    public func setWifiSsid(newWifiSsid: String) async throws {
        try sendMessage(type: .setWifiSsid, data: newWifiSsid.data)
        // TODO: - wait for wifiSsid event
    }

    public func setWifiPassword(newWifiPassword: String) async throws {
        try sendMessage(type: .setWifiPassword, data: newWifiPassword.data)
        // TODO: - wait for wifiPassword event
    }

    public func setWifiShouldConnect(newShouldConnect: Bool) async throws {
        try sendMessage(type: .setWifiShouldConnect, data: newShouldConnect.data)
        // TODO: - wait for shouldConnect event
    }

    // MARK: - Initialization

    init() {
        // MARK: - Battery Level Callbacks

        batteryLevelManager.onBatteryLevelUpdated = {
            [unowned self] in self.batteryLevel = $0
        }

        // MARK: - Device Information Callbacks

        deviceInformationManager.onTypeUpdated = {
            [unowned self] in self.deviceType = $0
        }
        deviceInformationManager.onNameUpdated = {
            [unowned self] in self.deviceName = $0
        }
        deviceInformationManager.onIsFullyInitialized = {
            [unowned self] in self.isFullyInitialized = $0
        }

        // MARK: - Wifi Information Callbacks

        wifiInformationManager.onSsidUpdated = {
            [unowned self] in self.wifiSsid = $0
        }
        wifiInformationManager.onPasswordUpdated = {
            [unowned self] in self.wifiPassword = $0
        }

        // MARK: - Motion Calibration Callbacks

        motionCalibrationDataManager.onIsFullyCalibrated = {
            [unowned self] in self.isMotionSensorFullyCalibrated = $0
        }

        // MARK: - Sensor Data Configurations Callbacks

        // TODO: - FILL

        // MARK: - Sensor Data Callbacks

        // TODO: - FILL
    }

    // MARK: - Bluetooth Connection

    static let bluetoothManager: UKBluetoothManager = .shared

    public static func scanForBluetoothDevices() {
        bluetoothManager.scanForDevices()
    }

    public static func stopScanningForBluetoothDevices() {
        bluetoothManager.stopScanningForDevices()
    }

    // MARK: - ConnectionManager Parsing

    func onConnectionMessage(type messageType: UKConnectionMessageType, data: Data) {
        switch messageType {
        case .batteryLevel:
            batteryLevelManager.parseBatteryLevel(data: data)

        case .getDeviceType, .setDeviceType:
            deviceInformationManager.parseType(data: data)
        case .getDeviceName, .setDeviceName:
            deviceInformationManager.parseName(data: data)

        case .getWifiSsid, .setWifiSsid:
            wifiInformationManager.parseSsid(data: data)
        case .getWifiPassword, .setWifiPassword:
            wifiInformationManager.parsePassword(data: data)
        case .getWifiShouldConnect, .setWifiShouldConnect:
            wifiInformationManager.parseShouldConnect(data: data)
        case .wifiIsConnected:
            wifiInformationManager.parseIsConnected(data: data)

        case .getSensorDataConfiguration, .setSensorDataConfiguration:
            sensorDataConfigurationsManager.parse(data)

        case .sensorData:
            sensorDataManager.parse(data)

        default:
            logger.error("uncaught connection message type \(messageType.name)")
        }
    }
}
