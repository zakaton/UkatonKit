import Foundation

extension UKMission {
    // MARK: - ConnectionManager Parsing

    func onConnectionMessage(type messageType: UKConnectionMessageType, data: Data, at offset: inout Data.Index) {
        // TODO: - make parsing return offset

        switch messageType {
        case .batteryLevel:
            batteryLevelManager.parseBatteryLevel(data: data)

        case .getDeviceType, .setDeviceType:
            deviceInformationManager.parseType(data: data)
        case .getDeviceName, .setDeviceName:
            deviceInformationManager.parseName(data: data)

        case .getWifiSsid, .setWifiSsid:
            wifiInformationManager.parseSsid(data: data)
        case .getWifiPassword, .setWifiPassword:
            wifiInformationManager.parsePassword(data: data)
        case .getWifiShouldConnect, .setWifiShouldConnect:
            wifiInformationManager.parseShouldConnect(data: data)
        case .wifiIsConnected:
            wifiInformationManager.parseIsConnected(data: data)

        case .getSensorDataConfigurations, .setSensorDataConfigurations:
            sensorDataConfigurationsManager.parse(data)

        case .sensorData:
            sensorDataManager.parse(data)

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

        try connectionManager.sendMessage(type: messageType, data: data)
    }

    // MARK: - DeviceInformationManager Interface

    func setDeviceType(newDeviceType: UKDeviceType) async throws {
        try sendMessage(type: .setDeviceType, data: newDeviceType.rawValue.data)
        // TODO: - wait for deviceType event
    }

    func setDeviceName(newDeviceName: String) async throws {
        try sendMessage(type: .setDeviceName, data: newDeviceName.data)
        // TODO: - wait for deviceName event
    }

    // MARK: - WifiManager Interface

    func setWifiSsid(newWifiSsid: String) async throws {
        try sendMessage(type: .setWifiSsid, data: newWifiSsid.data)
        // TODO: - wait for wifiSsid event
    }

    func setWifiPassword(newWifiPassword: String) async throws {
        try sendMessage(type: .setWifiPassword, data: newWifiPassword.data)
        // TODO: - wait for wifiPassword event
    }

    func setWifiShouldConnect(newShouldConnect: Bool) async throws {
        try sendMessage(type: .setWifiShouldConnect, data: newShouldConnect.data)
        // TODO: - wait for shouldConnect event
    }

    // MARK: - SensorDataConfigurationsManager Interface

    // TODO: - FILL

    // MARK: - HapticsManager Interface

    // TODO: - FILL
}
