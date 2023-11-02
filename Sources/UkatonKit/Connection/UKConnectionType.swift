import UkatonMacros

@EnumName
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
