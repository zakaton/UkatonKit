public typealias UKRawSensorDataType = UInt8
public protocol UKSensorDataType: Identifiable {
    var sensorType: UKSensorType { get }
    var rawValue: UKRawSensorDataType { get }
}

public extension UKSensorDataType {
    var id: UKRawSensorDataType { rawValue }
}
