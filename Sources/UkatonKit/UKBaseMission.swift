import Foundation
import OSLog
import StaticLogger

@StaticLogger
public class UKBaseMission: ObservableObject {
    // MARK: - Components

    var deviceInformationManager: UKDeviceInformationManager = .init()
    var sensorDataConfigurationsManager: UKSensorDataConfigurationsManager = .init()
    var sensorData: UKSensorData = .init()
    var motionCalibrationData: UKMotionCalibrationData = .init()
    var haptics: UKHaptics = .init()

    // MARK: - Convenience

    public private(set) var deviceType: UKDeviceType?
    public private(set) var deviceName: String?

    // MARK: - Initialization

    init() {
        // MARK: - Device Information Callbacks

        deviceInformationManager.onTypeUpdated = {
            [unowned self] deviceType in self.onDeviceTypeUpdated(deviceType)
        }
        deviceInformationManager.onNameUpdated = {
            [unowned self] deviceName in self.onDeviceNameUpdated(deviceName)
        }
        deviceInformationManager.onFullyInitialized = {
            [unowned self] in self.onDeviceInformationFullyInitialized()
        }

        // MARK: - Motion Calibration Callbacks

        motionCalibrationData.onFullyCalibrated = {
            [unowned self] in self.onFullyCalibrated()
        }
    }

    // MARK: - Connection

    // MARK: - Device Information Callbacks

    func onDeviceTypeUpdated(_ newDeviceType: UKDeviceType?) {
        deviceType = newDeviceType
        sensorDataConfigurationsManager.deviceType = deviceType
        sensorData.deviceType = deviceType
    }

    func onDeviceNameUpdated(_ newDeviceName: String?) {
        deviceName = newDeviceName
    }

    func onDeviceInformationFullyInitialized() {
        guard deviceType != nil else {
            logger.error("deviceType not defined, even after device is fully initialized")
            return
        }
        logger.debug("fully initialized device information")
    }

    // MARK: - Motion Calibration Callbacks

    func onFullyCalibrated() {
        logger.debug("fully calibrated")
    }
}
