import Foundation
import OSLog
import UkatonMacros

extension Date {
    static var now_ms: UInt64 {
        UInt64(now.timeIntervalSince1970 * 1000)
    }
}

protocol UKSensorDataComponent {
    var deviceType: UKDeviceType? { get set }
    mutating func parse(_ data: Data, at offset: inout Data.Index, until finalOffset: Data.Index)
}

@StaticLogger
public struct UKSensorDataManager {
    // MARK: - Device Type

    var deviceType: UKDeviceType? = nil {
        didSet {
            if oldValue != deviceType {
                for sensorType in sensorData.keys {
                    sensorData[sensorType]?.deviceType = deviceType
                }
            }
        }
    }

    // MARK: - Data

    typealias SensorData = [UKSensorType: UKSensorDataComponent]
    var sensorData: SensorData = {
        var _sensorData: SensorData = [:]
        UKSensorType.allCases.forEach { sensorType in
            let dataComponent: UKSensorDataComponent = switch sensorType {
            case .motion:
                UKMotionData()
            case .pressure:
                UKPressureData()
            }
            _sensorData[sensorType] = dataComponent
        }
        return _sensorData
    }()

    // MARK: - Subscripts

    private subscript(_ sensorType: UKSensorType) -> UKSensorDataComponent {
        sensorData[sensorType]!
    }

    public var motion: UKMotionData { self[.motion] as! UKMotionData }
    public var pressure: UKPressureData { self[.pressure] as! UKPressureData }

    // MARK: - Timestamps

    private var timestamp: UInt64 = 0
    public private(set) var lastTimeReceivedSensorData: UInt64 = 0

    private var timestampOffset: UInt64 = 0
    private var rawTimestamp: UInt16 = 0 {
        willSet {
            if newValue < rawTimestamp {
                timestampOffset += UInt64(UInt16.max) + 1
            }
        }
        didSet {
            timestamp = UInt64(rawTimestamp) + timestampOffset
        }
    }

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout Data.Index) {
        lastTimeReceivedSensorData = Date.now_ms
        rawTimestamp = .parse(from: data, at: &offset)

        let _self = self
        logger.debug("sensor data timestamp: \(_self.timestamp)ms")

        while offset < data.count {
            let rawSensorType: UKSensorType.RawValue = data.parse(at: &offset)

            guard let sensorType: UKSensorType = .init(rawValue: rawSensorType) else {
                logger.error("uncaught sensor type \(rawSensorType)")
                break
            }

            let sensorDataSize: UInt8 = data.parse(at: &offset)

            logger.debug("received \(sensorDataSize) bytes for sensor type \(sensorType.name)")

            let finalOffset = offset + Data.Index(sensorDataSize)
            sensorData[sensorType]?.parse(data, at: &offset, until: finalOffset)
        }
    }

    mutating func parse(_ data: Data) {
        var offset: Data.Index = 0
        parse(data, at: &offset)
    }
}
