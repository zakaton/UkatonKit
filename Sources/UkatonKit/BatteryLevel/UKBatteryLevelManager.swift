import Foundation
import OSLog
import UkatonMacros

public typealias UKBatteryLevel = UInt8

@StaticLogger
struct UKBatteryLevelManager {
    // MARK: - Battery Level

    private var batteryLevel: UKBatteryLevel? {
        didSet {
            onBatteryLevelUpdated?(batteryLevel)
        }
    }

    public var onBatteryLevelUpdated: ((UKBatteryLevel?) -> Void)?

    mutating func parseBatteryLevel(data: Data, at offset: inout Data.Index) {
        if offset < data.count {
            batteryLevel = data.parse(at: &offset)
        }
    }

    mutating func parseBatteryLevel(data: Data) {
        var offset: Data.Index = 0
        parseBatteryLevel(data: data, at: &offset)
    }

    // MARK: - Reset

    public mutating func reset() {
        logger.debug("resetting")
        batteryLevel = nil
    }
}
