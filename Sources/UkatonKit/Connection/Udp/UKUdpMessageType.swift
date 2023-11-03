import OSLog
import UkatonMacros

@EnumName
@StaticLogger
enum UKUdpMessageType: UInt8 {
    case ping
    
    case batteryLevel
    
    case getDeviceType
    case setDeviceType
    
    case getDeviceName
    case setDeviceName
    
    case motionCalibration
    
    case getSensorDataConfigurations
    case setSensorDataConfigurations
    
    case sensorData
    
    case setHapticsVibration
    case setRemoteReceivePort
    
    init?(connectionMessageType: UKConnectionMessageType) {
        let udpMessageType: Self? = switch connectionMessageType {
        case .getDeviceName:
            .getDeviceName
        case .setDeviceName:
            .setDeviceName
            
        case .getDeviceType:
            .getDeviceType
        case .setDeviceType:
            .setDeviceType
            
        case .getSensorDataConfigurations:
            .getSensorDataConfigurations
        case .setSensorDataConfigurations:
            .setSensorDataConfigurations
            
        case .setHapticsVibration:
            .setHapticsVibration
        
        default:
            nil
        }

        guard let udpMessageType else {
            Self.logger.debug("uncaught connection message type \(connectionMessageType.name)")
            return nil
        }

        self = udpMessageType
    }
    
    var shouldIncludeDataSize: Bool {
        switch self {
        case .setDeviceName,
             .setHapticsVibration,
             .setSensorDataConfigurations:
            true
        default:
            false
        }
    }
    
    var includesDataSize: Bool {
        switch self {
        case .getDeviceName, .setDeviceName,
             .getSensorDataConfigurations, .setSensorDataConfigurations:
            true
        default:
            false
        }
    }
    
    var connectionMessageType: UKConnectionMessageType? {
        switch self {
        case .getDeviceName:
            .getDeviceName
        case .setDeviceName:
            .setDeviceName
            
        case .getDeviceType:
            .getDeviceType
        case .setDeviceType:
            .setDeviceType
            
        case .getSensorDataConfigurations:
            .getSensorDataConfigurations
        case .setSensorDataConfigurations:
            .setSensorDataConfigurations
            
        default:
            nil
        }
    }
}
