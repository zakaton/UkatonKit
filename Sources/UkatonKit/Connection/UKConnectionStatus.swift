import OSLog
import UkatonMacros

@StaticLogger
@EnumName(accessLevel: "public")
public enum UKConnectionStatus: CaseIterable {
    case notConnected
    case connecting
    case connected
    case disconnecting

    public init?(from name: String) {
        guard let connectionStatus = Self.allCases.first(where: { $0.name == name }) else {
            Self.logger.error("uncaught connection status for \(name)")
            return nil
        }
        self = connectionStatus
    }
}
