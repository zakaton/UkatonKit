import Foundation
import OSLog
import UkatonMacros

public typealias UKBatteryLevel = UInt8

@StaticLogger
public struct UKDeviceInformationManager {
    // MARK: - Name

    public internal(set) var name: String? = nil

    mutating func parseName(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newName = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new device name \"\(newName)\"")
        name = newName
    }

    mutating func parseName(data: Data, at offset: inout Data.Index) {
        parseName(data: data, at: &offset, until: data.count)
    }

    mutating func parseName(data: Data) {
        var offset: Data.Index = 0
        parseName(data: data, at: &offset, until: data.count)
    }

    // MARK: - DeviceType

    public internal(set) var type: UKDeviceType? = nil

    mutating func parseType(data: Data, at offset: inout Data.Index) {
        if offset < data.count {
            let newTypeRawValue: UKDeviceType.RawValue = .parse(from: data, at: &offset)
            if let newType = UKDeviceType(rawValue: newTypeRawValue) {
                logger.debug("new type \(newType.name)")
                type = newType
            } else {
                logger.error("invalid device type enum \(newTypeRawValue)")
            }
        }
    }

    mutating func parseType(data: Data) {
        var offset: Data.Index = 0
        parseType(data: data, at: &offset)
    }

    // MARK: - Battery Level

    public internal(set) var batteryLevel: UKBatteryLevel?

    mutating func parseBatteryLevel(data: Data, at offset: inout Data.Index) {
        if offset < data.count {
            batteryLevel = data.parse(at: &offset)
        }
    }

    mutating func parseBatteryLevel(data: Data) {
        var offset: Data.Index = 0
        parseBatteryLevel(data: data, at: &offset)
    }
}
