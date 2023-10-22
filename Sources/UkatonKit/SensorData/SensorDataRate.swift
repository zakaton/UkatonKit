import Foundation

typealias SensorDataRate = UInt16
extension SensorDataRate {
    static func parse(from data: Data, at offset: inout UInt8, littleEndian: Bool = true) -> SensorDataRate {
        guard offset >= 0, offset + 2 <= data.count else {
            return 0
        }
        let bytes = data.subdata(in: Data.Index(offset) ..< Data.Index(offset + 2))
        let value = UInt16(bytes[0]) + (UInt16(bytes[1]) << 8)
        offset += 2
        return littleEndian ? value : value.byteSwapped
    }
}

extension SensorDataRate {
    func roundToTens() -> SensorDataRate {
        return self - (self % 10)
    }
}
