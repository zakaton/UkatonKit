import Foundation

struct SensorDataConfiguration<SensorDataType: Hashable & CaseIterable> {
    var dataRates: [SensorDataType: SensorDataRate] = [:]

    func serialize() {}

    var isConfigurationNonZero: Bool = false

    func parse(data: Data, offset: inout UInt8) {
        // FILL
    }
}

struct SensorDataConfigurations {
    var motionDataConfiguration: SensorDataConfiguration<MotionDataType> = .init()
    var pressureDataConfiguration: SensorDataConfiguration<PressureDataType> = .init()

    var deviceType: DeviceType? = nil

    public private(set) var areConfigurationsNonZero: Bool = false
    mutating func parse(data: Data, offset: inout UInt8) {
        var _areConfigurationsNonZero = false
        SensorDataType.allCases.forEach { sensorDataType in
            switch sensorDataType {
            case .motion:
                motionDataConfiguration.parse(data: data, offset: &offset)
                _areConfigurationsNonZero = _areConfigurationsNonZero || motionDataConfiguration.isConfigurationNonZero
            case .pressure:
                pressureDataConfiguration.parse(data: data, offset: &offset)
                _areConfigurationsNonZero = _areConfigurationsNonZero || pressureDataConfiguration.isConfigurationNonZero
            }
        }
        areConfigurationsNonZero = _areConfigurationsNonZero
    }

    mutating func parse(data: Data) {
        var offset: UInt8 = 0
        parse(data: data, offset: &offset)
    }

    func serialize() {
        motionDataConfiguration.serialize()
        pressureDataConfiguration.serialize()
    }

    mutating func reset() {
        deviceType = nil
    }
}
