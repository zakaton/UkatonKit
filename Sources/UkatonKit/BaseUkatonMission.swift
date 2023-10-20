import Foundation

public class BaseUkatonMission: ObservableObject {
    var deviceInformation: DeviceInformation = .init()
    var sensorDataConfigurations: SensorDataConfigurations = .init()
    var sensorData: SensorData = .init()
    var haptics: Haptics = .init()

    init() {
        deviceInformation.onFullyInitialized = { [unowned self] in self.onDeviceInformationFullyInitialized() }
    }

    func onDeviceInformationFullyInitialized() {
        sensorDataConfigurations.deviceType = deviceInformation.deviceType
    }
}
