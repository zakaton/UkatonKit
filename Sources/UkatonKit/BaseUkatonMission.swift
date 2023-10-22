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

    // MARK: - Initialization

    init() {
        deviceInformation.onFullyInitialized = {
            [unowned self] in self.onDeviceInformationFullyInitialized()
        }
    }

    // MARK: - Connection

    // MARK: - Callbacks

    func onDeviceInformationFullyInitialized() {
        logger.debug("fully initialized device information")
        sensorDataConfigurations.deviceType = deviceInformation.deviceType
    }
}
