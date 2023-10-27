import Foundation
import OSLog
import UkatonMacros

typealias UKSensorDataConfigurationManagers = [UKSensorType: UKSensorDataConfigurationManager]

public typealias UKMotionDataRates = [UKMotionDataType: UKSensorDataRate]
public typealias UKPressureDataRates = [UKPressureDataType: UKSensorDataRate]

public struct UKSensorDataConfigurations: Equatable {
    public var motion: UKMotionDataRates = .init()
    public var pressure: UKPressureDataRates = .init()

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        if lhs.motion != rhs.motion {
            return false
        }
        if lhs.pressure != rhs.pressure {
            return false
        }

        return true
    }
}

@StaticLogger
struct UKSensorDataConfigurationsManager {
    // MARK: - Device Type

    var deviceType: UKDeviceType?

    // MARK: - Configurations

    private var configurationManagers: UKSensorDataConfigurationManagers = {
        var _configurationManagers: UKSensorDataConfigurationManagers = [:]
        UKSensorType.allCases.forEach { sensorType in
            _configurationManagers[sensorType] = .init(sensorType: sensorType)
        }
        return _configurationManagers
    }()

    public var configurations: UKSensorDataConfigurations {
        get {
            .init(motion: motion, pressure: pressure)
        }
        set {
            motion = newValue.motion
            pressure = newValue.pressure
        }
    }

    // MARK: - Subscripting

    var motion: UKMotionDataRates {
        get { .from(genericSensorDataRates: self[.motion]) }
        set { self[.motion] = newValue.toGenericSensorDataRates() }
    }

    var pressure: UKPressureDataRates {
        get { .from(genericSensorDataRates: self[.pressure]) }
        set { self[.pressure] = newValue.toGenericSensorDataRates() }
    }

    private subscript(_ sensorType: UKSensorType) -> UKGenericSensorDataRates {
        get {
            configurationManagers[sensorType]!.dataRates
        }
        set(newValue) {
            configurationManagers[sensorType]!.dataRates = newValue
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
            configurationManagers[sensorDataType.sensorType]![sensorDataType.rawValue]
        }
        set(newValue) {
            configurationManagers[sensorDataType.sensorType]![sensorDataType.rawValue] = newValue
            onConfigurationsUpdate()
        }
    }

    // MARK: - Serialization

    private(set) var areConfigurationsNonZero: Bool = false
    private var shouldSerialize: Bool = false
    private mutating func onConfigurationsUpdate() {
        shouldSerialize = configurationManagers.values.contains { $0.shouldSerialize }
        areConfigurationsNonZero = configurationManagers.values.contains { $0.isConfigurationNonZero }
    }

    private static let maxSerializationLength = (UKSensorType.allCases.count * 2) + (3 * UKSensorType.totalNumberOfDataTypes)
    private var serialization: Data = .init(capacity: maxSerializationLength)

    private mutating func serialize() {
        serialization.removeAll(keepingCapacity: true)
        for var configuration in configurationManagers.values {
            if deviceType?.hasSensorType(configuration.sensorType) == false {
                continue
            }
            serialization.append(configuration.getSerialization())
        }
        for sensorType in configurationManagers.keys {
            if deviceType?.hasSensorType(sensorType) == false {
                continue
            }
            serialization.append(configurationManagers[sensorType]!.getSerialization())
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

    mutating func parse(_ data: Data, at offset: inout Data.Index) {
        UKSensorType.allCases.forEach { sensorType in
            configurationManagers[sensorType]?.parse(data, at: &offset)
        }
        onConfigurationsUpdate()
    }

    mutating func parse(_ data: Data) {
        var offset: Data.Index = 0
        parse(data, at: &offset)
    }

    mutating func reset() {
        deviceType = nil
        for sensorType in configurationManagers.keys {
            configurationManagers[sensorType]?.reset()
        }
        shouldSerialize = false
        areConfigurationsNonZero = false
    }
}
