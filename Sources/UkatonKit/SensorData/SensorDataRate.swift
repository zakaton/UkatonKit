typealias SensorDataRate = UInt16
extension SensorDataRate {
    func toUInt8Array(littleEndian: Bool = true) -> [UInt8] {
        let byte1: UInt8
        let byte2: UInt8

        if littleEndian {
            byte1 = UInt8(truncatingIfNeeded: self)
            byte2 = UInt8(truncatingIfNeeded: self >> 8)
        } else {
            byte1 = UInt8(truncatingIfNeeded: self >> 8)
            byte2 = UInt8(truncatingIfNeeded: self)
        }

        return [byte1, byte2]
    }
}

extension SensorDataRate {
    func roundToTens() -> SensorDataRate {
        return self - (self % 10)
    }
}
