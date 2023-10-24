public enum UKPressureDataType: UInt8, CaseIterable, UKSensorDataType {
    case pressureSingleByte
    case pressureDoubleByte
    case centerOfMass
    case mass
    case heelToToe

    var sensorType: UKSensorType { .pressure }

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
