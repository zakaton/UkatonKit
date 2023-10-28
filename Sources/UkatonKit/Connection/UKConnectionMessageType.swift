import UkatonMacros

@EnumName
enum UKConnectionMessageType {
    case batteryLevel
    case getDeviceType, setDeviceType
    case getDeviceName, setDeviceName
    case motionCalibration
    case getSensorDataConfiguration, setSensorDataConfiguration
    case sensorData
    case getWifiSsid, setWifiSsid
    case getWifiPassword, setWifiPassword
    case getWifiShouldConnect, setWifiShouldConnect
    case wifiIsConnected
    case getWifiIpAddress, setWifiIpAddress
    case setHapticsVibration
}
