import UkatonMacros

@EnumName
enum UKUdpMessageType: UInt8 {
    case ping
    
    case batteryLevel
    
    case getType
    case setType
    
    case getName
    case setName
    
    case motionCalibration
    
    case getSensorDataConfigurations
    case setSensorDataConfigurations
    
    case sensorData
    
    case vibration
    case setRemoteReceivePort
}
