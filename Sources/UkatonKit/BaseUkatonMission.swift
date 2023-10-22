import Foundation
import OSLog
import StaticLogger

@StaticLogger
public class BaseUkatonMission: ObservableObject {
    var logger: Logger { Self.logger }

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

    // MARK: - Callbacks

    func onDeviceInformationFullyInitialized() {
        sensorDataConfigurations.deviceType = deviceInformation.deviceType
    }
}
