import Foundation

extension UKMission {
    // MARK: - ConnectionManager Parsing

    func onConnectionMessage(type messageType: UKConnectionMessageType, data: Data, at offset: inout Data.Index) {
        switch messageType {
        case .batteryLevel:
            batteryLevelManager.parseBatteryLevel(data: data, at: &offset)

        case .getDeviceType, .setDeviceType:
            deviceInformationManager.parseType(data: data, at: &offset)
        case .getDeviceName, .setDeviceName:
            deviceInformationManager.parseName(data: data, at: &offset)

        case .getWifiSsid, .setWifiSsid:
            wifiInformationManager.parseSsid(data: data, at: &offset)
        case .getWifiPassword, .setWifiPassword:
            wifiInformationManager.parsePassword(data: data, at: &offset)
        case .getWifiShouldConnect, .setWifiShouldConnect:
            wifiInformationManager.parseShouldConnect(data: data, at: &offset)
        case .wifiIsConnected:
            wifiInformationManager.parseIsConnected(data: data, at: &offset)

        case .getSensorDataConfigurations, .setSensorDataConfigurations:
            sensorDataConfigurationsManager.parse(data, at: &offset)

        case .sensorData:
            sensorDataManager.parse(data, at: &offset)

        default:
            logger.error("uncaught connection message type \(messageType.name)")
        }
    }

    // MARK: - Send Message

    func sendMessage(type messageType: UKConnectionMessageType, data: Data) throws {
        guard let connectionManager else {
            throw UKConnectionManagerMessageError.noConnectionManager
        }
        guard connectionManager.status == .connected else {
            throw UKConnectionManagerMessageError.notConnected
        }

        guard connectionManager.allowedMessageTypes.contains(messageType) else {
            throw UKConnectionManagerMessageError.messageTypeNotImplemented(messageType)
        }

        logger.debug("sending message of type \(messageType.name)")

        try connectionManager.sendMessage(type: messageType, data: data)
    }

    // MARK: - DeviceInformationManager Interface

    func setDeviceType(newDeviceType: UKDeviceType) throws {
        try sendMessage(type: .setDeviceType, data: newDeviceType.rawValue.data)
    }

    func setDeviceName(newDeviceName: String) throws {
        try sendMessage(type: .setDeviceName, data: newDeviceName.data)
    }

    // MARK: - WifiManager Interface

    func setWifiSsid(newWifiSsid: String) throws {
        try sendMessage(type: .setWifiSsid, data: newWifiSsid.data)
    }

    func setWifiPassword(newWifiPassword: String) throws {
        try sendMessage(type: .setWifiPassword, data: newWifiPassword.data)
    }

    func setWifiShouldConnect(newShouldConnect: Bool) throws {
        try sendMessage(type: .setWifiShouldConnect, data: newShouldConnect.data)
    }

    // MARK: - SensorDataConfigurationsManager Interface

    // TODO: - FILL

    // MARK: - HapticsManager Interface

    // TODO: - FILL
}
