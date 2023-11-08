import UkatonMacros

@EnumName(accessLevel: "public")
public enum UKMotionCalibrationType: UInt8, CaseIterable, Identifiable {
    public var id: UInt8 { rawValue }

    case accelerometer
    case gyroscope
    case magnetometer
    case quaternion
}
