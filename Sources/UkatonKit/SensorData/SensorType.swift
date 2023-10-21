public enum SensorType: UInt8, CaseIterable {
    case motion
    case pressure

    var dataTypes: [RawSensorDataType] {
        let dataTypes = switch self {
        case .motion:
            MotionDataType.allCases.map { $0.rawValue }
        case .pressure:
            PressureDataType.allCases.map { $0.rawValue }
        }
        return dataTypes
    }

    func forEachDataType(_ body: (UInt8) -> Void) {
        switch self {
        case .motion:
            MotionDataType.allCases.forEach { body($0.rawValue) }
        case .pressure:
            PressureDataType.allCases.forEach { body($0.rawValue) }
        }
    }

    var numberOfDataTypes: Int {
        switch self {
        case .motion:
            return MotionDataType.allCases.count
        case .pressure:
            return PressureDataType.allCases.count
        }
    }

    static var maxNumberOfDataTypes: Int {
        allCases.reduce(0) { max($0, $1.numberOfDataTypes) }
    }

    static var totalNumberOfDataTypes: Int {
        allCases.reduce(0) { $0 + $1.numberOfDataTypes }
    }
}
