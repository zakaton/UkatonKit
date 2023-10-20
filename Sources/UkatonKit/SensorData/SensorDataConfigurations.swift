import Foundation

struct SensorDataConfiguration {
    var dataRates: [UInt8: SensorDataRate] = [:]

    func serialize() {}

    var isConfigurationNonZero: Bool = false

    func parse(data: Data, offset: inout UInt8) {
        // FILL
    }
}

struct SensorDataConfigurations {
    var deviceType: DeviceType?

    var configurations: [SensorDataType: SensorDataConfiguration] = {
        var _configurations: [SensorDataType: SensorDataConfiguration] = [:]
        SensorDataType.allCases.forEach { sensorDataType in
            _configurations[sensorDataType] = .init()
        }
        return _configurations
    }()

    public private(set) var areConfigurationsNonZero: Bool = false
    mutating func parse(data: Data, offset: inout UInt8) {
        var _areConfigurationsNonZero = false
        configurations.values.forEach { configuration in
            configuration.parse(data: data, offset: &offset)
            _areConfigurationsNonZero = _areConfigurationsNonZero || configuration.isConfigurationNonZero
        }
        areConfigurationsNonZero = _areConfigurationsNonZero
    }

    mutating func parse(data: Data) {
        var offset: UInt8 = 0
        parse(data: data, offset: &offset)
    }

    func serialize() {
        configurations.values.forEach { $0.serialize() }
    }

    mutating func reset() {
        deviceType = nil
    }
}
