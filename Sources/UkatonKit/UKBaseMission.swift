import Foundation
import OSLog
import StaticLogger

@StaticLogger
public class UKBaseMission: ObservableObject {
    // MARK: - Components

    var deviceInformation: UKDeviceInformation = .init()
    var sensorDataConfigurations: UKSensorDataConfigurations = .init()
    var sensorData: UKSensorData = .init()
    var motionCalibrationData: UKMotionCalibrationData = .init()
    var haptics: UKHaptics = .init()

    // MARK: - Convenience

    var deviceType: UKDeviceType? {
        deviceInformation.deviceType
    }

    // MARK: - Initialization

    init() {
        deviceInformation.onFullyInitialized = {
            [unowned self] in self.onDeviceInformationFullyInitialized()
        }
        motionCalibrationData.onFullyCalibrated = {
            [unowned self] in self.onFullyCalibrated()
        }
    }

    // MARK: - Connection

    // MARK: - Callbacks

    func onDeviceInformationFullyInitialized() {
        guard deviceType != nil else {
            logger.error("deviceType not defined, even after device is fully initialized")
            return
        }
        logger.debug("fully initialized device information")

        sensorDataConfigurations.deviceType = deviceType
        sensorData.deviceType = deviceType
    }

    func onFullyCalibrated() {
        logger.debug("fully calibrated")
    }
}
