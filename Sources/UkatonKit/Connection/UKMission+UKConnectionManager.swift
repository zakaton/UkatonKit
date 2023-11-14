import Foundation

public extension UKMission {
    // MARK: - Connection

    internal func createConnectionManager(type connectionType: UKConnectionType) -> any UKConnectionManager {
        var _connectionType = connectionType
        if connectionType.requiresWifi, isConnectedToWifi == false || ipAddress == nil {
            logger.warning("device is not connected to wifi - defaulting to bluetooth")
            _connectionType = .bluetooth
        }

        return switch _connectionType {
        case .bluetooth:
            UKBluetoothConnectionManager(peripheral: peripheral!)
        case .udp:
            UKUdpConnectionManager(ipAddress: ipAddress!)
        }
    }

    func connect(type _connectionType: UKConnectionType? = nil) {
        guard connectionStatus == .notConnected || connectionStatus == .disconnecting else {
            let _self = self
            logger.warning("cannot connect while in connection state \(_self.connectionStatus.name)")
            return
        }
        if connectionManager == nil || (_connectionType != nil && connectionType != _connectionType) {
            connectionManager = createConnectionManager(type: _connectionType ?? .bluetooth)
        }
        guard connectionManager != nil else {
            logger.error("no connectionManager defined")
            return
        }
        connectionManager!.connect()
    }

    func disconnect() {
        guard connectionManager != nil else {
            logger.error("no connectionManager defined")
            return
        }
        connectionManager?.disconnect()
    }

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
            let newSensorDataConfigurations: UKSensorDataConfigurations = .init(from: data, at: &offset)
            sensorDataConfigurationsSubject.send(newSensorDataConfigurations)
            updateCheckSensorDataTimer()

        case .sensorData:
            sensorData.parse(data, at: &offset)

        case .motionCalibration:
            parseMotionCalibration(data, at: &offset)

        case .bluetoothRSSI:
            parseBluetoothRSSI(data, at: &offset)

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

    // MARK: - Device Information

    func setDeviceType(_ newDeviceType: UKDeviceType) throws {
        try sendMessage(type: .setDeviceType, data: newDeviceType.rawValue.data)
    }

    func setName(_ newName: String) throws {
        try sendMessage(type: .setName, data: newName.data)
    }

    // MARK: - Wifi Information

    func setWifiSsid(_ newWifiSsid: String) throws {
        try sendMessage(type: .setWifiSsid, data: newWifiSsid.data)
    }

    func setWifiPassword(_ newWifiPassword: String) throws {
        try sendMessage(type: .setWifiPassword, data: newWifiPassword.data)
    }

    func setWifiShouldConnect(_ newWifiShouldConnect: Bool) throws {
        try sendMessage(type: .setWifiShouldConnect, data: newWifiShouldConnect.data)
    }

    // MARK: - Sensor Data Configurations

    func setSensorDataConfigurations(_ newSensorDataConfigurations: UKSensorDataConfigurations) throws {
        try sendMessage(type: .setSensorDataConfigurations, data: newSensorDataConfigurations.data(deviceType: deviceType, relativeTo: sensorDataConfigurations))
    }

    func resendSensorDataConfigurations() throws {
        try sendMessage(type: .setSensorDataConfigurations, data: sensorDataConfigurations.withoutZeros.data(deviceType: deviceType))
    }

    func clearSensorDataConfigurations() throws {
        let newSensorDataConfiguratons: UKSensorDataConfigurations = .init()
        try setSensorDataConfigurations(newSensorDataConfiguratons)
    }

    // MARK: - Vibration

    func vibrate(waveformEffects: [UKVibrationWaveformEffect]) throws {
        try sendMessage(type: .triggerVibration, data: serializeVibration(waveformEffects: waveformEffects))
    }

    func vibrate(waveformEffect: UKVibrationWaveformEffect) throws {
        try vibrate(waveformEffects: [waveformEffect])
    }

    func vibrate(waveforms: [UKVibrationWaveform]) throws {
        try sendMessage(type: .triggerVibration, data: serializeVibration(waveforms: waveforms))
    }

    func vibrate(waveform: UKVibrationWaveform) throws {
        try vibrate(waveforms: [waveform])
    }
}
