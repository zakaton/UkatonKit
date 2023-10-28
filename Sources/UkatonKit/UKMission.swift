import Foundation
import OSLog
import UkatonMacros

@StaticLogger
public class UKMission: ObservableObject {
    // MARK: - Components

    var batteryLevelManager: UKBatteryLevelManager = .init()
    var deviceInformationManager: UKDeviceInformationManager = .init()
    var wifiInformationManager: UKWifiInformationManager = .init()
    var sensorDataConfigurationsManager: UKSensorDataConfigurationsManager = .init()
    var sensorDataManager: UKSensorDataManager = .init()
    var motionCalibrationDataManager: UKMotionCalibrationDataManager = .init()
    var hapticsManager: UKHapticsManager = .init()

    // MARK: - Connection

    var connectionManager: UKConnectionManager? {
        willSet {
            if var connectionManager {
                connectionManager.onMessageReceived = nil
            }
        }
        didSet {
            if var connectionManager {
                connectionManager.onMessageReceived = { [unowned self] type, data in
                    self.onConnectionMessage(type: type, data: data)
                }
            }
        }
    }

    var connectionType: UKConnectionType? {
        connectionManager?.type
    }

    // MARK: - Device Information

    public private(set) var deviceType: UKDeviceType? {
        didSet {
            sensorDataConfigurationsManager.deviceType = deviceType
            sensorDataManager.deviceType = deviceType
        }
    }

    public private(set) var deviceName: String?

    public private(set) var isFullyInitialized: Bool = false {
        didSet {
            if isFullyInitialized {
                logger.debug("Fully initialized!")
            }
        }
    }

    public private(set) var batteryLevel: UKBatteryLevel? {
        didSet {
            sensorDataConfigurationsManager.deviceType = deviceType
            sensorDataManager.deviceType = deviceType
        }
    }

    // MARK: - Motion Calibration

    public private(set) var isMotionSensorFullyCalibrated: Bool = false {
        didSet {
            if isMotionSensorFullyCalibrated {
                logger.debug("Motion Sensor is fully calibrated!")
            }
        }
    }

    // MARK: - Device Information

    public private(set) var wifiSsid: String?
    public private(set) var wifiPassword: String?

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
    }

    // MARK: - Bluetooth Connection

    static let bluetoothManager: UKBluetoothManager = .shared

    public static func scanForBluetoothDevices() {
        bluetoothManager.scanForDevices()
    }

    public static func stopScanningForBluetoothDevices() {
        bluetoothManager.stopScanningForDevices()
    }

    // MARK: - ConnectionManager Setters

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
            logger.debug("uncaught connection message \(messageType.name)")
        }
    }
}
