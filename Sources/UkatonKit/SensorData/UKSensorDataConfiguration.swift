import Foundation
import OSLog
import StaticLogger

typealias UKSensorDataRates = [UKRawSensorDataType: UKSensorDataRate]

@StaticLogger
struct UKSensorDataConfiguration {
    // MARK: - SensorType

    let sensorType: UKSensorType
    init(sensorType: UKSensorType) {
        self.sensorType = sensorType
    }

    // MARK: - Configuration

    var dataRates: UKSensorDataRates = [:] {
        didSet {
            onConfigurationUpdate()
        }
    }

    var isConfigurationNonZero: Bool = false
    private var lastSerializedDataRates: UKSensorDataRates?

    public subscript(_ dataType: UKRawSensorDataType) -> UKSensorDataRate {
        get {
            dataRates[dataType] ?? 0
        }
        set(_newValue) {
            let newValue = _newValue.roundToTens()
            if dataRates[dataType] != newValue {
                dataRates[dataType] = newValue
                onConfigurationUpdate()
            }
        }
    }

    private mutating func onConfigurationUpdate() {
        shouldSerialize = dataRates != lastSerializedDataRates
        isConfigurationNonZero = dataRates.values.contains { $0 > 0 }
    }

    // MARK: - Serialization

    private static let maxSerializationLength: Int = 2 * (3 * UKSensorType.maxNumberOfDataTypes)
    private var serialization: Data = .init(capacity: maxSerializationLength)

    var shouldSerialize: Bool = false
    private mutating func serialize() {
        serialization.removeAll(keepingCapacity: true)
        dataRates.forEach { dataType, dataRate in
            serialization.append(dataType.data)
            serialization.append(dataRate.data)
        }

        let _self = self
        logger.debug("serialized configuration: \(_self.serialization.debugDescription)")

        lastSerializedDataRates = dataRates
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
        sensorType.forEachDataType { dataType in
            if offset + 2 < data.count {
                let dataRate: UKSensorDataRate = .parse(from: data, at: &offset)
                dataRates[dataType] = dataRate
            }
            else {
                logger.error("offset out of bounds")
            }
        }

        let _self = self
        logger.debug("parsed configuration: \(_self.dataRates.debugDescription)")

        lastSerializedDataRates = dataRates
        onConfigurationUpdate()
    }

    mutating func reset() {
        dataRates = [:]
        lastSerializedDataRates = nil
        shouldSerialize = false
        isConfigurationNonZero = false
    }
}
