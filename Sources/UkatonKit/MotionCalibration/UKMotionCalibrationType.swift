import UkatonMacros

@EnumName
public enum UKMotionCalibrationType: UInt8, CaseIterable {
    case accelerometer
    case gyroscope
    case magnetometer
    case quaternion
}
