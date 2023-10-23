import Foundation
import OSLog
import StaticLogger

typealias MotionDataRates = [UKMotionDataType: UKSensorDataRate]
typealias PressureDataRates = [UKPressureDataType: UKSensorDataRate]

@StaticLogger
struct UKSensorDataConfigurations {
    // MARK: - Device Type

    var deviceType: UKDeviceType?

    // MARK: - Configurations

    private typealias RawSensorDataConfigurations = [UKSensorType: UKSensorDataConfiguration]

    private var configurations: RawSensorDataConfigurations = {
        var _configurations: RawSensorDataConfigurations = [:]
        UKSensorType.allCases.forEach { sensorType in
            _configurations[sensorType] = .init(sensorType: sensorType)
        }
        return _configurations
    }()

    // MARK: - Subscripting

    var motion: MotionDataRates {
        get { self[.motion] as! MotionDataRates }
        set { self[.motion] = newValue as! UKSensorDataRates }
    }

    var pressure: PressureDataRates {
        get { self[.pressure] as! PressureDataRates }
        set { self[.pressure] = newValue as! UKSensorDataRates }
    }

    private subscript(_ sensorType: UKSensorType) -> UKSensorDataRates {
        get {
            configurations[sensorType]!.dataRates
        }
        set(newValue) {
            configurations[sensorType]!.dataRates = newValue
            onConfigurationsUpdate()
        }
    }

    subscript(motionDataType: UKMotionDataType) -> UKSensorDataRate {
        get {
            self[motionDataType as UKSensorDataType]
        }
        set(newValue) {
            self[motionDataType as UKSensorDataType] = newValue
        }
    }

    subscript(pressureDataType: UKPressureDataType) -> UKSensorDataRate {
        get {
            self[pressureDataType as UKSensorDataType]
        }
        set(newValue) {
            self[pressureDataType as UKSensorDataType] = newValue
        }
    }

    private subscript(sensorDataType: UKSensorDataType) -> UKSensorDataRate {
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

    private static let maxSerializationLength = (UKSensorType.allCases.count * 2) + (3 * UKSensorType.totalNumberOfDataTypes)
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
