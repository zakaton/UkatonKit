enum PressureDataType: UInt8, CaseIterable, SensorDataType {
    case pressureSingleByte
    case pressureDoubleByte
    case centerOfMass
    case mass
    case heelToToe

    var sensorType: SensorType { .pressure }

    var name: String {
        switch self {
        case .pressureSingleByte:
            "pressure (single byte)"
        case .pressureDoubleByte:
            "pressure (double byte)"
        case .centerOfMass:
            "center of mass"
        case .mass:
            "mass"
        case .heelToToe:
            "heel-to-toe"
        }
    }
}
