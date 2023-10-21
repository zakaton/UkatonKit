typealias RawSensorDataType = UInt8
protocol SensorDataType {
    var sensorType: SensorType { get }
    var rawValue: RawSensorDataType { get }
}
