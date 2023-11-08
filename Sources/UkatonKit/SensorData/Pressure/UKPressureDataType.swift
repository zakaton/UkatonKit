import UkatonMacros

@EnumName(accessLevel: "public")
public enum UKPressureDataType: UInt8, CaseIterable, UKSensorDataType {
    case pressureSingleByte
    case pressureDoubleByte
    case centerOfMass
    case mass
    case heelToToe

    public var sensorType: UKSensorType { .pressure }
}
