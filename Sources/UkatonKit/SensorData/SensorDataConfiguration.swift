import Foundation
import OSLog
import StaticLogger

typealias SensorDataRates = [RawSensorDataType: SensorDataRate]

@StaticLogger
struct SensorDataConfiguration {
    // MARK: - SensorType

    let sensorType: SensorType
    init(sensorType: SensorType) {
        self.sensorType = sensorType
    }

    // MARK: - Configuration

    var dataRates: SensorDataRates = [:] {
        didSet {
            onConfigurationUpdate()
        }
    }

    var isConfigurationNonZero: Bool = false
    private var lastSerializedDataRates: SensorDataRates?

    public subscript(_ dataType: RawSensorDataType) -> SensorDataRate {
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

    private static let maxSerializationLength: Int = 2 * (3 * SensorType.maxNumberOfDataTypes)
    private var serialization: Data = .init(capacity: maxSerializationLength)

    var shouldSerialize: Bool = false
    private mutating func serialize() {
        serialization.removeAll(keepingCapacity: true)
        dataRates.forEach { dataType, dataRate in
            serialization.append(contentsOf: [dataType])
            serialization.append(contentsOf: dataRate.toUInt8Array())
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
                let dataRate: SensorDataRate = .parse(from: data, at: &offset)
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
