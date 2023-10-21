public enum DeviceType: UInt8, CaseIterable {
    case motionModule
    case leftInsole
    case rightInsole

    var isInsole: Bool { self != .motionModule }
    var insoleSide: InsoleSide? {
        guard self.isInsole else { return nil }
        return self == .leftInsole ? .left : .right
    }

    func hasSensorType(_ sensorType: SensorType) -> Bool {
        sensorType == .motion || self.isInsole
    }

    var availableSensorTypes: [SensorType] {
        SensorType.allCases.filter { self.hasSensorType($0) }
    }
}

public enum InsoleSide: UInt8, CaseIterable {
    case left
    case right
}
