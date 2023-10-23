public enum DeviceType: UInt8, CaseIterable {
    case motionModule
    case leftInsole
    case rightInsole

    public var isInsole: Bool { self != .motionModule }
    public var insoleSide: InsoleSide? {
        guard self.isInsole else { return nil }
        return self == .leftInsole ? .left : .right
    }

    public func hasSensorType(_ sensorType: SensorType) -> Bool {
        sensorType == .motion || self.isInsole
    }

    public var availableSensorTypes: [SensorType] {
        SensorType.allCases.filter { self.hasSensorType($0) }
    }
}

public enum InsoleSide: UInt8, CaseIterable {
    case left
    case right
}
