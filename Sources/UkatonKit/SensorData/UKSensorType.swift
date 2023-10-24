public enum UKSensorType: UInt8, CaseIterable {
    case motion
    case pressure

    var dataTypes: [UKRawSensorDataType] {
        let dataTypes = switch self {
        case .motion:
            UKMotionDataType.allCases.map { $0.rawValue }
        case .pressure:
            UKPressureDataType.allCases.map { $0.rawValue }
        }
        return dataTypes
    }

    func forEachDataType(_ body: (UInt8) -> Void) {
        switch self {
        case .motion:
            UKMotionDataType.allCases.forEach { body($0.rawValue) }
        case .pressure:
            UKPressureDataType.allCases.forEach { body($0.rawValue) }
        }
    }

    var numberOfDataTypes: Int {
        switch self {
        case .motion:
            return UKMotionDataType.allCases.count
        case .pressure:
            return UKPressureDataType.allCases.count
        }
    }

    static var maxNumberOfDataTypes: Int {
        allCases.reduce(0) { max($0, $1.numberOfDataTypes) }
    }

    static var totalNumberOfDataTypes: Int {
        allCases.reduce(0) { $0 + $1.numberOfDataTypes }
    }

    var name: String {
        switch self {
        case .motion:
            "motion"
        case .pressure:
            "pressure"
        }
    }
}