import UkatonMacros

@EnumName(accessLevel: "public")
public enum UKMotionDataType: UInt8, CaseIterable, UKSensorDataType {
    case acceleration
    case gravity
    case linearAcceleration
    case rotationRate
    case magnetometer
    case quaternion

    public var sensorType: UKSensorType { .motion }
}
