import UkatonMacros

@EnumName
public enum UKMotionDataType: UInt8, CaseIterable, UKSensorDataType {
    case acceleration
    case gravity
    case linearAcceleration
    case rotationRate
    case magnetometer
    case quaternion

    var sensorType: UKSensorType { .motion }
}
