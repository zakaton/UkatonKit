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
    
    case triggerVibration
    case setRemoteReceivePort
    
    init?(connectionMessageType: UKConnectionMessageType) {
        let udpMessageType: Self? = switch connectionMessageType {
        case .getName:
            .getDeviceName
        case .setName:
            .setDeviceName
            
        case .getDeviceType:
            .getDeviceType
        case .setDeviceType:
            .setDeviceType
            
        case .getSensorDataConfigurations:
            .getSensorDataConfigurations
        case .setSensorDataConfigurations:
            .setSensorDataConfigurations
            
        case .triggerVibration:
            .triggerVibration
        
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
             .triggerVibration,
             .setSensorDataConfigurations:
            true
        default:
            false
        }
    }
    
    var includesDataSize: Bool {
        switch self {
        case .getDeviceName, .setDeviceName, .sensorData:
            true
        default:
            false
        }
    }
    
    var connectionMessageType: UKConnectionMessageType? {
        switch self {
        case .batteryLevel:
            .batteryLevel
            
        case .getDeviceName:
            .getName
        case .setDeviceName:
            .setName
            
        case .getDeviceType:
            .getDeviceType
        case .setDeviceType:
            .setDeviceType
            
        case .getSensorDataConfigurations:
            .getSensorDataConfigurations
        case .setSensorDataConfigurations:
            .setSensorDataConfigurations
            
        case .sensorData:
            .sensorData
            
        default:
            nil
        }
    }
}
