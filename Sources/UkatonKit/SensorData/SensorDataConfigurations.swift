import Foundation

struct SensorDataConfiguration {
    let sensorType: SensorType

    var dataRates: [UInt8: SensorDataRate] = [:]

    func serialize() {}

    var isConfigurationNonZero: Bool = false

    func parse(data: Data, offset: inout UInt8) {
        // FILL
        sensorType.forEachDataType { dataType in
            print(dataType)
        }
    }

    mutating func reset() {
        dataRates = [:]
    }
}

struct SensorDataConfigurations {
    var deviceType: DeviceType?

    var configurations: [SensorType: SensorDataConfiguration] = {
        var _configurations: [SensorType: SensorDataConfiguration] = [:]
        SensorType.allCases.forEach { sensorType in
            _configurations[sensorType] = .init(sensorType: sensorType)
        }
        return _configurations
    }()

    public subscript(_ motionDataType: MotionDataType) -> SensorDataRate {
        get {
            configurations[.motion]!.dataRates[motionDataType.rawValue] ?? .init(rate: 0)
        }
        set(newValue) {
            configurations[.motion]!.dataRates[motionDataType.rawValue] = newValue
        }
    }

    public subscript(_ pressureDataType: PressureDataType) -> SensorDataRate {
        get {
            configurations[.pressure]!.dataRates[pressureDataType.rawValue] ?? .init(rate: 0)
        }
        set(newValue) {
            configurations[.pressure]!.dataRates[pressureDataType.rawValue] = newValue
        }
    }

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
        for var configuration in configurations.values {
            configuration.reset()
        }
    }
}
