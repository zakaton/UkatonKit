import CoreBluetooth
import OSLog
import UkatonMacros

@EnumName
@StaticLogger
enum UKBluetoothServiceIdentifier: String, CaseIterable, UKBluetoothContainerIdentifier {
    static var uuidCache: [Self: CBUUID] = [:]
    static var uuidsCache: [CBUUID] = []

    case main = "0000"
    case batteryLevel = "0x180F"

    static var characteristicUUIDsCache: [Self: [CBUUID]] = [:]

    var characteristicUUIDs: [CBUUID] {
        if let cachedCharacteristicUUIDs = Self.characteristicUUIDsCache[self] {
            return cachedCharacteristicUUIDs
        } else {
            let _characteristicsUUIDs = characteristics.map { $0.uuid }
            Self.characteristicUUIDsCache[self] = _characteristicsUUIDs
            return _characteristicsUUIDs
        }
    }

    var characteristics: [UKBluetoothCharacteristicIdentifier] {
        switch self {
        case .main:
            return [
                .deviceName, .deviceType,
                .motionCalibration,
                .sensorDataConfiguration, .sensorData,
                .wifiSSID, .wifiPassword, .wifiConnect, .wifiIsConnected, .wifiIPAddress,
                .hapticsVibration
            ]
        case .batteryLevel:
            return [.batteryLevel]
        }
    }

    init?(service: CBService) {
        guard let serviceCase = Self.allCases.first(where: { $0.uuid == service.uuid }) else {
            Self.logger.error("unknown service \(service.uuid)")
            return nil
        }
        self = serviceCase
    }
}
