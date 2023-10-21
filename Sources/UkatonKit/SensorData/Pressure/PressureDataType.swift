enum PressureDataType: UInt8, CaseIterable, SensorDataType {
    case pressureSingleByte
    case pressureDoubleByte
    case centerOfMass
    case mass
    case heelToToe

    var sensorType: SensorType { .pressure }
}
