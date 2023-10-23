public enum MotionCalibrationType: UInt8, CaseIterable {
    case accelerometer
    case gyroscope
    case magnetometer
    case quaternion

    var name: String {
        switch self {
        case .accelerometer:
            "Accelerometer"
        case .gyroscope:
            "Gyroscope"
        case .magnetometer:
            "Magnetometer"
        case .quaternion:
            "Quaternion"
        }
    }
}
