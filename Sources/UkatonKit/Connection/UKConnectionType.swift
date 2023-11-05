import UkatonMacros

@EnumName(accessLevel: "public")
public enum UKConnectionType {
    case bluetooth
    case udp

    public var requiresWifi: Bool {
        switch self {
        case .bluetooth:
            false
        case .udp:
            true
        }
    }
}
