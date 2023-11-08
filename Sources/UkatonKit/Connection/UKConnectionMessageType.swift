import UkatonMacros

@EnumName
enum UKConnectionMessageType: CaseIterable {
    case batteryLevel
    case getDeviceType, setDeviceType
    case getName, setName
    case motionCalibration
    case getSensorDataConfigurations, setSensorDataConfigurations
    case sensorData
    case getWifiSsid, setWifiSsid
    case getWifiPassword, setWifiPassword
    case getWifiShouldConnect, setWifiShouldConnect
    case wifiIsConnected
    case getWifiIpAddress
    case triggerHapticsVibration
}
