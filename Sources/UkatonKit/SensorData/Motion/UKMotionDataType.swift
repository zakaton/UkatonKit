public enum UKMotionDataType: UInt8, CaseIterable, UKSensorDataType {
    case acceleration
    case gravity
    case linearAcceleration
    case rotationRate
    case magnetometer
    case quaternion

    var sensorType: UKSensorType { .motion }

    var name: String {
        switch self {
        case .acceleration:
            "acceleration"
        case .gravity:
            "gravity"
        case .linearAcceleration:
            "linear acceleration"
        case .rotationRate:
            "rotation rate"
        case .magnetometer:
            "magnetometer"
        case .quaternion:
            "quaternion"
        }
    }
}
