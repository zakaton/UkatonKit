import Foundation

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

    static func parse(from data: Data, at offset: inout UInt8, littleEndian: Bool = true) -> SensorDataRate {
        guard offset >= 0, offset + 2 <= data.count else {
            return 0
        }
        let bytes = data.subdata(in: Data.Index(offset) ..< Data.Index(offset + 2))
        let value = UInt16(bytes[0]) + (UInt16(bytes[1]) << 8)
        return littleEndian ? value : value.byteSwapped
    }
}

extension SensorDataRate {
    func roundToTens() -> SensorDataRate {
        return self - (self % 10)
    }
}
