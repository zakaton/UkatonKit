import Combine

public protocol UKSensorDataConfigurable {
    var sensorDataConfigurations: UKSensorDataConfigurations { get }
    var sensorDataConfigurationsSubject: CurrentValueSubject<UKSensorDataConfigurations, Never> { get }
    func setSensorDataConfigurations(_ newSensorDataConfigurations: UKSensorDataConfigurations) throws
}

public extension UKSensorDataConfigurable {
    func resendSensorDataConfigurations() throws {
        try setSensorDataConfigurations(sensorDataConfigurations.withoutZeros)
    }

    func clearSensorDataConfigurations() throws {
        let newSensorDataConfiguratons: UKSensorDataConfigurations = .init()
        try setSensorDataConfigurations(newSensorDataConfiguratons)
    }
}
