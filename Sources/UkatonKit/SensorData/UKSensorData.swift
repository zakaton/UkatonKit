import Foundation
import OSLog
import UkatonMacros

public typealias UKTimestamp = UInt64

extension Date {
    static var now_ms: UKTimestamp {
        UKTimestamp(now.timeIntervalSince1970 * 1000)
    }
}

protocol UKSensorDataComponent {
    var deviceType: UKDeviceType? { get set }
    mutating func parse(_ data: Data, at offset: inout Data.Index, until finalOffset: Data.Index, timestamp: UKTimestamp)
}

@StaticLogger
public struct UKSensorData {
    // MARK: - Data

    public private(set) var motion: UKMotionData = .init()
    public private(set) var pressure: UKPressureData = .init()

    // MARK: - Device Type

    var deviceType: UKDeviceType? = nil {
        didSet {
            if oldValue != deviceType {
                motion.deviceType = deviceType
                pressure.deviceType = deviceType
            }
        }
    }

    // MARK: - Timestamp

    private var timestamp: UKTimestamp = 0
    private(set) var lastTimeReceivedSensorData: UKTimestamp = 0

    private var timestampOffset: UKTimestamp = 0
    private var rawTimestamp: UInt16 = 0 {
        willSet {
            if newValue < rawTimestamp {
                logger.debug("timestamp overflow")
                timestampOffset += UKTimestamp(UInt16.max) + 1
            }
        }
        didSet {
            timestamp = UKTimestamp(rawTimestamp) + timestampOffset
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

            switch sensorType {
            case .motion:
                motion.parse(data, at: &offset, until: finalOffset, timestamp: timestamp)
            case .pressure:
                pressure.parse(data, at: &offset, until: finalOffset, timestamp: timestamp)
            }
        }
    }

    mutating func parse(_ data: Data) {
        var offset: Data.Index = 0
        parse(data, at: &offset)
    }
}
