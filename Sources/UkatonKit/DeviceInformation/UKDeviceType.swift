import OSLog
import UkatonMacros

@StaticLogger
@EnumName(accessLevel: "public")
public enum UKDeviceType: UInt8, CaseIterable, Identifiable {
    public var id: Self { self }

    case motionModule
    case leftInsole
    case rightInsole

    public var isInsole: Bool { self != .motionModule }
    public var insoleSide: UKInsoleSide? {
        guard self.isInsole else { return nil }
        return self == .leftInsole ? .left : .right
    }

    public func hasSensorType(_ sensorType: UKSensorType) -> Bool {
        sensorType == .motion || self.isInsole
    }

    public var availableSensorTypes: [UKSensorType] {
        UKSensorType.allCases.filter { self.hasSensorType($0) }
    }

    public init?(from name: String) {
        guard let deviceType = Self.allCases.first(where: { $0.name == name }) else {
            Self.logger.error("uncaught connection type for \(name)")
            return nil
        }
        self = deviceType
    }
}
