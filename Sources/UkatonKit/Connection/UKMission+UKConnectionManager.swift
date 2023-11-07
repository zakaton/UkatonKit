import Foundation

public extension UKMission {
    // MARK: - ConnectionManager Parsing

    internal func onConnectionMessage(type messageType: UKConnectionMessageType, data: Data, at offset: inout Data.Index) {
        switch messageType {
        case .batteryLevel:
            parseBatteryLevel(data: data, at: &offset)
        case .getDeviceType, .setDeviceType:
            parseDeviceType(data: data, at: &offset)
        case .getName, .setName:
            parseName(data: data, at: &offset)

        case .getWifiSsid, .setWifiSsid:
            parseWifiSsid(data: data, at: &offset)
        case .getWifiPassword, .setWifiPassword:
            parseWifiPassword(data: data, at: &offset)
        case .getWifiShouldConnect, .setWifiShouldConnect:
            parseShouldConnectToWifi(data: data, at: &offset)
        case .getWifiIpAddress:
            parseIpAddress(data: data, at: &offset)
        case .wifiIsConnected:
            parseIsConnectedToWifi(data: data, at: &offset)

        case .getSensorDataConfigurations, .setSensorDataConfigurations:
            sensorDataConfigurations.parse(data, at: &offset)

        case .sensorData:
            sensorData.parse(data, at: &offset)

        case .motionCalibration:
            motionCalibrationData.parse(data, at: &offset)

        default:
            logger.error("uncaught connection message type \(messageType.name)")
        }
    }

    // MARK: - Send Message

    internal func sendMessage(type messageType: UKConnectionMessageType, data: Data) throws {
        guard let connectionManager else {
            logger.error("no connection manager")
            throw UKConnectionManagerMessageError.noConnectionManager
        }
        guard connectionManager.status == .connected else {
            logger.error("not connected")
            throw UKConnectionManagerMessageError.notConnected
        }

        guard connectionManager.allowedMessageTypes.contains(messageType) else {
            logger.error("messageType not implemented \(messageType.name)")
            throw UKConnectionManagerMessageError.messageTypeNotImplemented(messageType)
        }

        logger.debug("sending message of type \(messageType.name)")

        try connectionManager.sendMessage(type: messageType, data: data)
    }

    // MARK: - DeviceInformationManager Interface

    func setDeviceType(_ newDeviceType: UKDeviceType) throws {
        try sendMessage(type: .setDeviceType, data: newDeviceType.rawValue.data)
    }

    func setName(_ newName: String) throws {
        try sendMessage(type: .setName, data: newName.data)
    }

    // MARK: - WifiManager Interface

    func setWifiSsid(_ newWifiSsid: String) throws {
        try sendMessage(type: .setWifiSsid, data: newWifiSsid.data)
    }

    func setWifiPassword(_ newWifiPassword: String) throws {
        try sendMessage(type: .setWifiPassword, data: newWifiPassword.data)
    }

    func setWifiShouldConnect(_ newWifiShouldConnect: Bool) throws {
        try sendMessage(type: .setWifiShouldConnect, data: newWifiShouldConnect.data)
    }

    // MARK: - SensorDataConfigurationsManager Interface

    // TODO: - FILL

    // MARK: - HapticsManager Interface

    // TODO: - FILL
}
