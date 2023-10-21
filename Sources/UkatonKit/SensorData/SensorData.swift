import Foundation

extension Date {
    static var now_ms: UInt64 {
        UInt64(now.timeIntervalSince1970 * 1000)
    }
}

public struct SensorData {
    // MARK: Timestamps

    public private(set) var timestamp: UInt64 = 0
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

    func parseSensorData(data: inout Data, offset: inout UInt8) {}
}
