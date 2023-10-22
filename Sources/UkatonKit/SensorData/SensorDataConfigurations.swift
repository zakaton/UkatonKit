import Foundation
import OSLog
import StaticLogger

typealias MotionDataRates = [MotionDataType: SensorDataRate]
typealias PressureDataRates = [PressureDataType: SensorDataRate]

@StaticLogger
struct SensorDataConfigurations {
    // MARK: - Device Type

    var deviceType: DeviceType?

    // MARK: - Configurations

    private typealias RawSensorDataConfigurations = [SensorType: SensorDataConfiguration]

    private var configurations: RawSensorDataConfigurations = {
        var _configurations: RawSensorDataConfigurations = [:]
        SensorType.allCases.forEach { sensorType in
            _configurations[sensorType] = .init(sensorType: sensorType)
        }
        return _configurations
    }()

    // MARK: - Subscripting

    var motion: MotionDataRates {
        get { self[.motion] as! MotionDataRates }
        set { self[.motion] = newValue as! SensorDataRates }
    }

    var pressure: PressureDataRates {
        get { self[.pressure] as! PressureDataRates }
        set { self[.pressure] = newValue as! SensorDataRates }
    }

    private subscript(_ sensorType: SensorType) -> SensorDataRates {
        get {
            configurations[sensorType]!.dataRates
        }
        set(newValue) {
            configurations[sensorType]!.dataRates = newValue
            onConfigurationsUpdate()
        }
    }

    subscript(motionDataType: MotionDataType) -> SensorDataRate {
        get {
            self[motionDataType as SensorDataType]
        }
        set(newValue) {
            self[motionDataType as SensorDataType] = newValue
        }
    }

    subscript(pressureDataType: PressureDataType) -> SensorDataRate {
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

    // MARK: - Serialization

    private(set) var areConfigurationsNonZero: Bool = false
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
            if deviceType?.hasSensorType(configuration.sensorType) == false {
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

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout UInt8) {
        for var configuration in configurations.values {
            configuration.parse(data, at: &offset)
        }
    }

    mutating func parse(_ data: Data) {
        var offset: UInt8 = 0
        parse(data, at: &offset)
        onConfigurationsUpdate()
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
