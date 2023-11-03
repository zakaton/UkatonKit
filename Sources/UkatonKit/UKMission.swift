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
                connectionManager.onMessageReceived = { [unowned self] type, data, offset in
                    self.onConnectionMessage(type: type, data: data, at: &offset)
                }
                connectionManager.onStatusUpdated = { [unowned self] in
                    self.connectionStatus = $0
                }
                connectionType = connectionManager.type
            }
        }
    }

    @Published public var connectionType: UKConnectionType? = nil
    var connectionStatus: UKConnectionStatus = .notConnected {
        didSet {
            if connectionStatus == .connected && !isFullyInitialized {
                // TODO: - FILL
            }
        }
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

    // MARK: - Initialization

    init(connectionManager: UKConnectionManager) {
        defer {
            self.connectionManager = connectionManager
        }

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
}
