typealias UKRawSensorDataType = UInt8
protocol UKSensorDataType {
    var sensorType: UKSensorType { get }
    var rawValue: UKRawSensorDataType { get }
}
