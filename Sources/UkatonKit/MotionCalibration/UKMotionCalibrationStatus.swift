import UkatonMacros

@EnumName(accessLevel: "public")
public enum UKMotionCalibrationStatus: UInt8 {
    case unreliable
    case low
    case medium
    case high
}
