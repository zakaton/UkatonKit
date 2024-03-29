import Foundation
import OSLog
import UkatonMacros

// UInt64 modulo is weird on watchOS...
#if os(watchOS)
public typealias UKTimestamp = UInt32
#else
public typealias UKTimestamp = UInt64
#endif

public extension UKTimestamp {
    var string: String {
        let totalSeconds = self / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let remainingMilliseconds = self % 1000

        return .init(format: "%02d:%02d:%03d", minutes, seconds, remainingMilliseconds)
    }
}

protocol UKSensorDataComponent {
    var deviceType: UKDeviceType { get set }
    mutating func parse(_ data: Data, at offset: inout Data.Index, until finalOffset: Data.Index, timestamp: UKTimestamp)
}

@StaticLogger
public class UKSensorData {
    // MARK: - Data

    public private(set) var motion: UKMotionData = .init()
    public internal(set) var pressure: UKPressureData = .init()

    // MARK: - Device Type

    var deviceType: UKDeviceType = .motionModule {
        didSet {
            motion.deviceType = deviceType
            pressure.deviceType = deviceType
        }
    }

    // MARK: - Timestamp

    public private(set) var timestamp: UKTimestamp = 0
    private(set) var lastTimeReceivedSensorData: Date = .now

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

    func parse(_ data: Data, at offset: inout Data.Index) {
        lastTimeReceivedSensorData = Date.now
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

    func parse(_ data: Data) {
        var offset: Data.Index = 0
        parse(data, at: &offset)
    }
}
