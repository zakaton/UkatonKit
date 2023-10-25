import UkatonMacros

@EnumName
public enum UKPressureDataType: UInt8, CaseIterable, UKSensorDataType {
    case pressureSingleByte
    case pressureDoubleByte
    case centerOfMass
    case mass
    case heelToToe

    var sensorType: UKSensorType { .pressure }
}
