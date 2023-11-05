import UkatonMacros

@EnumName(accessLevel: "public")
public enum UKConnectionStatus {
    case notConnected
    case connecting
    case connected
    case disconnecting
}
