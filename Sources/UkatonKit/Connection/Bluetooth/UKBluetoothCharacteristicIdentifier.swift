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

    case wifiSsid = "7001"
    case wifiPassword = "7002"
    case wifiShouldConnect = "7003"
    case wifiIsConnected = "7004"
    case wifiIpAddress = "7005"

    case triggerVibration = "d000"

    init?(characteristic: CBCharacteristic) {
        guard let characteristicIdentifier = Self.allCases.first(where: { $0.uuid == characteristic.uuid }) else {
            Self.logger.error("unknown characteristic \(characteristic.uuid)")
            return nil
        }
        self = characteristicIdentifier
    }

    var connectionMessageType: UKConnectionMessageType {
        switch self {
        case .deviceName:
            return .getName
        case .batteryLevel:
            return .batteryLevel
        case .deviceType:
            return .getDeviceType
        case .motionCalibration:
            return .motionCalibration
        case .sensorDataConfiguration:
            return .getSensorDataConfigurations
        case .sensorData:
            return .sensorData
        case .wifiSsid:
            return .getWifiSsid
        case .wifiPassword:
            return .getWifiPassword
        case .wifiShouldConnect:
            return .getWifiShouldConnect
        case .wifiIsConnected:
            return .wifiIsConnected
        case .wifiIpAddress:
            return .getWifiIpAddress
        case .triggerVibration:
            return .triggerVibration
        }
    }

    init?(connectionMessageType: UKConnectionMessageType) {
        let serviceIdentifier: Self? = switch connectionMessageType {
        case .getName, .setName:
            .deviceName
        case .getDeviceType, .setDeviceType:
            .deviceType

        case .getSensorDataConfigurations, .setSensorDataConfigurations:
            .sensorDataConfiguration

        case .getWifiSsid, .setWifiSsid:
            .wifiSsid
        case .getWifiPassword, .setWifiPassword:
            .wifiPassword
        case .getWifiShouldConnect, .setWifiShouldConnect:
            .wifiShouldConnect

        case .triggerVibration:
            .triggerVibration

        // TODO: - FILL

        default:
            nil
        }

        guard let serviceIdentifier else {
            Self.logger.error("uncaught connection message type \(connectionMessageType.name)")
            return nil
        }

        self = serviceIdentifier
    }
}
