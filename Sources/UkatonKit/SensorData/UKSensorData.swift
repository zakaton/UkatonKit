import Foundation
import OSLog
import StaticLogger

extension Date {
    static var now_ms: UInt64 {
        UInt64(now.timeIntervalSince1970 * 1000)
    }
}

protocol UKSensorDataComponent {
    var deviceType: UKDeviceType? { get set }
    mutating func parse(_ data: Data, at offset: inout UInt8, until finalOffset: UInt8)
}

@StaticLogger
public struct UKSensorData {
    // MARK: - Device Type

    var deviceType: UKDeviceType? {
        didSet {
            if oldValue != deviceType {
                for var dataComponent in sensorData.values {
                    dataComponent.deviceType = deviceType
                }
            }
        }
    }

    // MARK: - Data

    private typealias RawSensorData = [UKSensorType: UKSensorDataComponent]
    private var sensorData: RawSensorData = {
        var _data: RawSensorData = [:]
        UKSensorType.allCases.forEach { sensorType in
            let dataComponent: UKSensorDataComponent = switch sensorType {
            case .motion:
                UKMotionData()
            case .pressure:
                UKPressureData()
            }
            _data[sensorType] = dataComponent
        }
        return _data
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

    mutating func parse(_ data: Data, at offset: inout UInt8) {
        lastTimeReceivedSensorData = Date.now_ms
        rawTimestamp = UInt16.parse(from: data, at: &offset)

        let _self = self
        logger.debug("sensor data timestamp: \(_self.timestamp)ms")

        while offset < data.count {
            let rawSensorType = data[Data.Index(offset)]
            offset += 1

            guard let sensorType: UKSensorType = .init(rawValue: rawSensorType) else {
                logger.error("uncaught sensor type \(rawSensorType)")
                break
            }

            let sensorDataSize = data[Data.Index(offset)]
            offset += 1

            logger.debug("received \(sensorDataSize) bytes for sensor type \(sensorType.name)")

            let finalOffset = offset + sensorDataSize
            sensorData[sensorType]?.parse(data, at: &offset, until: finalOffset)
        }
    }

    mutating func parse(_ data: Data) {
        var offset: UInt8 = 0
        parse(data, at: &offset)
    }
}