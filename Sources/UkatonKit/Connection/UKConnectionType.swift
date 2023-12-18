import OSLog
import UkatonMacros

@StaticLogger
@EnumName(accessLevel: "public")
public enum UKConnectionType: CaseIterable {
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

    public init?(from name: String) {
        guard let connectionType = Self.allCases.first(where: { $0.name == name }) else {
            Self.logger.error("uncaught connection type for \(name)")
            return nil
        }
        self = connectionType
    }
}
