import Foundation

public typealias UKBatteryLevel = UInt8
extension UKBatteryLevel {
    static let notSet: UKBatteryLevel = 101
}

extension UKMission {
    // MARK: - Name

    func parseName(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newName = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new device name \"\(newName)\"")
        name = newName
    }

    func parseName(data: Data, at offset: inout Data.Index) {
        parseName(data: data, at: &offset, until: data.count)
    }

    func parseName(data: Data) {
        var offset: Data.Index = 0
        parseName(data: data, at: &offset, until: data.count)
    }

    // MARK: - DeviceType

    func parseDeviceType(data: Data, at offset: inout Data.Index) {
        if offset < data.count {
            let newTypeRawValue: UKDeviceType.RawValue = .parse(from: data, at: &offset)
            if let newDeviceType = UKDeviceType(rawValue: newTypeRawValue) {
                logger.debug("new type \(newDeviceType.name)")
                deviceType = newDeviceType
            } else {
                logger.error("invalid device type enum \(newTypeRawValue)")
            }
        }
    }

    func parseDeviceType(data: Data) {
        var offset: Data.Index = 0
        parseDeviceType(data: data, at: &offset)
    }

    // MARK: - Battery Level

    func parseBatteryLevel(data: Data, at offset: inout Data.Index) {
        if offset < data.count {
            let newBatteryLevel: UKBatteryLevel = data.parse(at: &offset)
            logger.debug("new battery level: \(newBatteryLevel)")
            batteryLevelSubject.send(newBatteryLevel)
        }
    }

    func parseBatteryLevel(data: Data) {
        var offset: Data.Index = 0
        parseBatteryLevel(data: data, at: &offset)
    }
}

public extension UKMission {
    func setDeviceType(_ newDeviceType: UKDeviceType) throws {
        try sendMessage(type: .setDeviceType, data: newDeviceType.rawValue.data)
    }

    func setName(_ newName: String) throws {
        try sendMessage(type: .setName, data: newName.data)
    }
}
