import Foundation
import OSLog
import StaticLogger

@StaticLogger
public class BaseUkatonMission: ObservableObject {
    // MARK: - Components

    var deviceInformation: DeviceInformation = .init()
    var sensorDataConfigurations: SensorDataConfigurations = .init()
    var sensorData: SensorData = .init()
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
}
