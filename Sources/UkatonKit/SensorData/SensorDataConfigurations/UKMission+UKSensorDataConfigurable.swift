import Foundation

extension UKMission: UKSensorDataConfigurable {
    public func setSensorDataConfigurations(_ newSensorDataConfigurations: UKSensorDataConfigurations) throws {
        try sendMessage(type: .setSensorDataConfigurations, data: newSensorDataConfigurations.data(deviceType: deviceType, relativeTo: sensorDataConfigurations))
    }
}
