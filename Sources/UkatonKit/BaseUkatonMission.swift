import Foundation

public class BaseUkatonMission: ObservableObject {
    var deviceInformation: DeviceInformation = .init()
    var sensorDataManager: SensorDataManager = .init()
    var hapticsManager: HapticsManager = .init()
}
