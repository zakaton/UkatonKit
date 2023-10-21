import Foundation
import OSLog

typealias SensorDataRates = [SensorDataType: SensorDataRate]

struct SensorDataConfiguration {
    static let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: Self.self))
    var logger: Logger { Self.logger }

    let sensorType: SensorType
    init(sensorType: SensorType) {
        self.sensorType = sensorType
    }

    var dataRates: SensorDataRates = [:] {
        didSet {
            onDataRatesUpdate()
        }
    }

    var lastSerializedDataRates: SensorDataRates?

    var isConfigurationNonZero: Bool = false
    public subscript(_ dataType: SensorDataType) -> SensorDataRate {
        get {
            dataRates[dataType] ?? 0
        }
        set(_newValue) {
            let newValue = _newValue.roundToTens()
            if dataRates[dataType] != newValue {
                dataRates[dataType] = newValue
                onDataRatesUpdate()
            }
        }
    }

    private mutating func onDataRatesUpdate() {
        shouldSerialize = dataRates != lastSerializedDataRates
        isConfigurationNonZero = dataRates.values.contains { $0 > 0 }
    }

    static let maxSerializationLength: Int = 2 * (3 * SensorType.maxNumberOfDataTypes)
    var serialization: Data = .init(capacity: maxSerializationLength)

    var shouldSerialize: Bool = false
    mutating func serialize() {
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

    mutating func parse(data: Data, offset: inout UInt8) {
        sensorType.forEachDataType { dataType in
            print(dataType)
            // FILL
        }
        lastSerializedDataRates = dataRates
    }

    mutating func reset() {
        dataRates = [:]
        lastSerializedDataRates = nil
        shouldSerialize = false
        isConfigurationNonZero = false
    }
}
