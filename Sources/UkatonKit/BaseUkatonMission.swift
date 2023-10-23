import Foundation
import OSLog
import StaticLogger

@StaticLogger
public class BaseUkatonMission: ObservableObject {
    // MARK: - Components

    var deviceInformation: DeviceInformation = .init()
    var sensorDataConfigurations: SensorDataConfigurations = .init()
    var sensorData: SensorData = .init()
    var motionCalibrationData: MotionCalibrationData = .init()
    var haptics: Haptics = .init()

    // MARK: - Convenience

    var deviceType: DeviceType? {
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
