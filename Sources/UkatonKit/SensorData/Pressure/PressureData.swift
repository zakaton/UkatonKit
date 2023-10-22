import Foundation
import OSLog
import StaticLogger

@StaticLogger
public struct PressureData: SensorDataComponent {
    // MARK: - Device Type

    var deviceType: DeviceType? = nil {
        didSet {
            if oldValue != deviceType {
                // TODO: - FILL
            }
        }
    }

    // MARK: - Data

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout UInt8, until finalOffset: UInt8) {
        // TODO: - FILL
    }
}
