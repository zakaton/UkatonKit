import UkatonMacros

@EnumName(accessLevel: "public")
public enum UKPressureDataType: UInt8, CaseIterable, UKSensorDataType, Nameable {
    case pressureSingleByte
    case pressureDoubleByte
    case centerOfMass
    case mass
    case heelToToe

    public var sensorType: UKSensorType { .pressure }
    public var isPressure: Bool {
        switch self {
        case .pressureSingleByte, .pressureDoubleByte:
            true
        default:
            false
        }
    }
}
