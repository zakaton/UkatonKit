enum UKConnectionManagerMessageError: Error {
    case noConnectionManager
    case notConnected
    case messageTypeNotImplemented(UKConnectionMessageType)
    case bluetoothError(String)
    case udpError(String)
}
