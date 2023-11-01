import CoreBluetooth

protocol UKBluetoothContainerIdentifier: Hashable, CaseIterable, RawRepresentable where RawValue == String {
    var rawValue: String { get }
    var name: String { get }
    var uuidString: String { get }

    var uuid: CBUUID { get }
    static var uuidCache: [Self: CBUUID] { get set }

    static var allUUIDs: [CBUUID] { get }
    static var uuidsCache: [CBUUID] { get set }
}

extension UKBluetoothContainerIdentifier {
    var uuidString: String {
        switch name {
        case "main", "battery level":
            rawValue
        default:
            "5691eddf-\(rawValue)-4420-b7a5-bb8751ab5181"
        }
    }

    var uuid: CBUUID {
        if let cachedUUID = Self.uuidCache[self] {
            return cachedUUID
        } else {
            let uuid = CBUUID(string: uuidString)
            Self.uuidCache[self] = uuid
            return uuid
        }
    }

    static var allUUIDs: [CBUUID] {
        if !uuidsCache.isEmpty {
            return uuidsCache
        } else {
            let uuids = allCases.map { $0.uuid }
            Self.uuidsCache = uuids
            return uuids
        }
    }
}
