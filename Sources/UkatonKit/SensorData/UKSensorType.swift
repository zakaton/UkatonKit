import UkatonMacros

@EnumName
public enum UKSensorType: UInt8, CaseIterable {
    case motion
    case pressure

    func forEachDataType(_ body: (UInt8) -> Void) {
        switch self {
        case .motion:
            UKMotionDataType.allCases.forEach { body($0.rawValue) }
        case .pressure:
            UKPressureDataType.allCases.forEach { body($0.rawValue) }
        }
    }

    func forEachDataTypeName(_ body: (String) -> Void) {
        switch self {
        case .motion:
            UKMotionDataType.allCases.forEach { body($0.name) }
        case .pressure:
            UKPressureDataType.allCases.forEach { body($0.name) }
        }
    }
}
