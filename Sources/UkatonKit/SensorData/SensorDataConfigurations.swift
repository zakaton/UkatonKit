import Foundation
import OSLog

struct SensorDataConfigurations {
    private static let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: Self.self))
    private var logger: Logger { Self.logger }

    var deviceType: DeviceType?

    private typealias RawSensorDataConfigurations = [SensorType: SensorDataConfiguration]

    private var configurations: RawSensorDataConfigurations = {
        var _configurations: RawSensorDataConfigurations = [:]
        SensorType.allCases.forEach { sensorType in
            _configurations[sensorType] = .init(sensorType: sensorType)
        }
        return _configurations
    }()

    private subscript(_ sensorType: SensorType) -> SensorDataRates {
        get {
            configurations[sensorType]!.dataRates
        }
        set(newValue) {
            configurations[sensorType]!.dataRates = newValue
            onConfigurationsUpdate()
        }
    }

    public subscript(motionDataType: MotionDataType) -> SensorDataRate {
        get {
            self[motionDataType as SensorDataType]
        }
        set(newValue) {
            self[motionDataType as SensorDataType] = newValue
        }
    }

    public subscript(pressureDataType: PressureDataType) -> SensorDataRate {
        get {
            self[pressureDataType as SensorDataType]
        }
        set(newValue) {
            self[pressureDataType as SensorDataType] = newValue
        }
    }

    private subscript(sensorDataType: SensorDataType) -> SensorDataRate {
        get {
            configurations[sensorDataType.sensorType]![sensorDataType.rawValue]
        }
        set(newValue) {
            configurations[sensorDataType.sensorType]![sensorDataType.rawValue] = newValue
            onConfigurationsUpdate()
        }
    }

    var areConfigurationsNonZero: Bool = false
    private var shouldSerialize: Bool = false
    private mutating func onConfigurationsUpdate() {
        shouldSerialize = configurations.values.contains { $0.shouldSerialize }
        areConfigurationsNonZero = configurations.values.contains { $0.isConfigurationNonZero }
    }

    private static let maxSerializationLength = (SensorType.allCases.count * 2) + (3 * SensorType.totalNumberOfDataTypes)
    private var serialization: Data = .init(capacity: maxSerializationLength)

    private mutating func serialize() {
        serialization.removeAll(keepingCapacity: true)
        for var configuration in configurations.values {
            if configuration.sensorType == .pressure, deviceType == .motionModule {
                continue
            }
            serialization.append(configuration.getSerialization())
        }

        let _self = self
        logger.debug("serialized configurations: \(_self.serialization.debugDescription)")
    }

    mutating func getSerialization() -> Data {
        if shouldSerialize {
            serialize()
            shouldSerialize = false
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
        shouldSerialize = false
        areConfigurationsNonZero = false
    }
}
