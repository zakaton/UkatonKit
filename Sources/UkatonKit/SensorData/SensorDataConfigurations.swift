import Foundation
import OSLog

struct SensorDataConfigurations {
    static let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: Self.self))
    var logger: Logger { Self.logger }

    var deviceType: DeviceType?

    typealias RawSensorDataConfigurations = [SensorType: SensorDataConfiguration]

    private var configurations: RawSensorDataConfigurations = {
        var _configurations: RawSensorDataConfigurations = [:]
        SensorType.allCases.forEach { sensorType in
            _configurations[sensorType] = .init(sensorType: sensorType)
        }
        return _configurations
    }()

    public subscript(_ sensorType: SensorType) -> SensorDataRates {
        get {
            configurations[sensorType]!.dataRates
        }
        set(newValue) {
            configurations[sensorType]!.dataRates = newValue
        }
    }

    public subscript(motionDataType: MotionDataType) -> SensorDataRate {
        get {
            configurations[.motion]![motionDataType.rawValue]
        }
        set(newValue) {
            configurations[.motion]![motionDataType.rawValue] = newValue
        }
    }

    public subscript(pressureDataType: PressureDataType) -> SensorDataRate {
        get {
            configurations[.pressure]![pressureDataType.rawValue]
        }
        set(newValue) {
            configurations[.pressure]![pressureDataType.rawValue] = newValue
        }
    }

    var areConfigurationsNonZero: Bool {
        configurations.values.contains { $0.isConfigurationNonZero }
    }

    var shouldSerialize: Bool {
        configurations.values.contains { $0.shouldSerialize }
    }

    static let maxSerializationLength = (SensorType.allCases.count * 2) + (3 * SensorType.totalNumberOfDataTypes)
    var serialization: Data = .init(capacity: maxSerializationLength)

    mutating func serialize() {
        serialization.removeAll(keepingCapacity: true)
        for var configuration in configurations.values {
            serialization.append(configuration.getSerialization())
        }

        let _self = self
        logger.debug("serialized configurations: \(_self.serialization.debugDescription)")
    }

    mutating func getSerialization() -> Data {
        if shouldSerialize {
            serialize()
        }
        return serialization
    }

    mutating func parse(data: Data, offset: inout UInt8) {
        for var configuration in configurations.values {
            configuration.parse(data: data, offset: &offset)
        }
    }

    mutating func parse(data: Data) {
        var offset: UInt8 = 0
        parse(data: data, offset: &offset)
    }

    mutating func reset() {
        deviceType = nil
        for var configuration in configurations.values {
            configuration.reset()
        }
    }
}
