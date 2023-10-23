public enum UKDeviceType: UInt8, CaseIterable {
    case motionModule
    case leftInsole
    case rightInsole

    public var isInsole: Bool { self != .motionModule }
    public var insoleSide: InsoleSide? {
        guard self.isInsole else { return nil }
        return self == .leftInsole ? .left : .right
    }

    public func hasSensorType(_ sensorType: UKSensorType) -> Bool {
        sensorType == .motion || self.isInsole
    }

    public var availableSensorTypes: [UKSensorType] {
        UKSensorType.allCases.filter { self.hasSensorType($0) }
    }
}

public enum InsoleSide: UInt8, CaseIterable {
    case left
    case right
}
