import Foundation

// MARK: - Number to Data

extension Data {
    func object<T>(at offset: inout UInt8) -> T {
        let size = MemoryLayout<T>.size
        let value = subdata(in: Data.Index(offset) ..< self.index(Data.Index(offset), offsetBy: size))
            .withUnsafeBytes { $0.load(as: T.self) }
        offset += UInt8(size)
        return value
    }
}

extension FixedWidthInteger {
    static func parse(from data: Data, at offset: inout UInt8, littleEndian: Bool) -> Self {
        let size = MemoryLayout<Self>.size
        let value = data.subdata(in: Data.Index(offset) ..< data.index(Data.Index(offset), offsetBy: size))
            .withUnsafeBytes { $0.load(as: Self.self) }
        offset += UInt8(size)

        return littleEndian ? value.littleEndian : value.bigEndian
    }
}

extension BinaryFloatingPoint {
    static func parse(from data: Data, at offset: inout UInt8, littleEndian: Bool) -> Self {
        let size = MemoryLayout<Self>.size
        let value = data.subdata(in: Data.Index(offset) ..< data.index(Data.Index(offset), offsetBy: size))
            .withUnsafeBytes { $0.load(as: Self.self) }
        offset += UInt8(size)

        if littleEndian {
            return value
        } else {
            return value
        }
    }
}

// MARK: - Data to Number

extension Numeric {
    var data: Data {
        var source = self
        // return Data(bytes: &source, count: MemoryLayout<Self>.size)
        return withUnsafeBytes(of: &source) { Data($0) }
    }
}

extension FixedWidthInteger {
    func data(littleEndian: Bool) -> Data {
        var source = littleEndian ? self.littleEndian : self.bigEndian
        // return Data(bytes: &source, count: MemoryLayout<Self>.size)
        return withUnsafeBytes(of: &source) { Data($0) }
    }
}

// MARK: - Data to [UInt8]

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

// MARK: - [UInt8] to Data

extension Array where Element == UInt8 {
    var data: Data {
        return .init(self)
    }
}
