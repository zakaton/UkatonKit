enum MotionDataType: UInt8, CaseIterable, SensorDataType {
    case acceleration
    case gravity
    case linearAcceleration
    case rotationRate
    case magnetometer
    case quaternion

    var sensorType: SensorType { .motion }
}
