import CoreBluetooth
import OSLog
import UkatonMacros

@EnumName
@StaticLogger
enum UKBluetoothCharacteristicIdentifier: String, CaseIterable, UKBluetoothContainerIdentifier {
    static var uuidCache: [Self: CBUUID] = [:]
    static var uuidsCache: [CBUUID] = []

    case batteryLevel = "0x2A19"

    case deviceType = "3001"

    case deviceName = "4001"

    case motionCalibration = "5001"

    case sensorDataConfiguration = "6001"
    case sensorData = "6002"

    case wifiSSID = "7001"
    case wifiPassword = "7002"
    case wifiConnect = "7003"
    case wifiIsConnected = "7004"
    case wifiIPAddress = "7005"

    case haptics = "d000"

    init?(characteristic: CBCharacteristic) {
        guard let characteristicCase = Self.allCases.first(where: { $0.uuid == characteristic.uuid }) else {
            Self.logger.error("unknown characteristic \(characteristic.uuid)")
            return nil
        }
        self = characteristicCase
    }
}
