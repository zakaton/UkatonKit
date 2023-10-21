public enum SensorType: UInt8, CaseIterable {
    case motion
    case pressure

    func forEachDataType(_ body: (UInt8) -> Void) {
        switch self {
        case .motion:
            MotionDataType.allCases.forEach { body($0.rawValue) }
        case .pressure:
            PressureDataType.allCases.forEach { body($0.rawValue) }
        }
    }
}
