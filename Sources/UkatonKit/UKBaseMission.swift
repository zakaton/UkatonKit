import Foundation
import OSLog
import StaticLogger

@StaticLogger
public class UKBaseMission: ObservableObject {
    // MARK: - Components

    var deviceInformationManager: UKDeviceInformationManager = .init()
    var sensorDataConfigurationsManager: UKSensorDataConfigurationsManager = .init()
    var sensorDataManager: UKSensorDataManager = .init()
    var motionCalibrationDataManager: UKMotionCalibrationDataManager = .init()
    var hapticsManager: UKHapticsManager = .init()

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

    // MARK: - Motion Calibration

    public private(set) var isMotionSensorFullyCalibrated: Bool = false {
        didSet {
            if isMotionSensorFullyCalibrated {
                logger.debug("Motion Sensor is fully calibrated!")
            }
        }
    }

    // MARK: - Initialization

    init() {
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

        // MARK: - Motion Calibration Callbacks

        motionCalibrationDataManager.onIsFullyCalibrated = {
            [unowned self] in self.isMotionSensorFullyCalibrated = $0
        }
    }

    // MARK: - Connection
}
