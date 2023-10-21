import Foundation
import OSLog

public class BaseUkatonMission: ObservableObject {
    // MARK: Logging

    private static let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: BaseUkatonMission.self))
    private var logger: Logger { Self.logger }

    // MARK: Components

    var deviceInformation: DeviceInformation = .init()
    var sensorDataConfigurations: SensorDataConfigurations = .init()
    var sensorData: SensorData = .init()
    var haptics: Haptics = .init()

    // MARK: Initialization

    init() {
        deviceInformation.onFullyInitialized = { [unowned self] in self.onDeviceInformationFullyInitialized() }
    }

    // MARK: Callbacks

    func onDeviceInformationFullyInitialized() {
        sensorDataConfigurations.deviceType = deviceInformation.deviceType
    }
}
