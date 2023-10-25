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
    static func parse(from data: Data, at offset: inout UInt8, littleEndian: Bool = true) -> Self {
        let value: Self = data.object(at: &offset)
        return littleEndian ? value.littleEndian : value.bigEndian
    }
}

extension Float32 {
    static func parse(from data: Data, at offset: inout UInt8, littleEndian: Bool = true) -> Self {
        var value: Self = data.object(at: &offset)

        if littleEndian != (UInt32(littleEndian: 1) == 1) {
            value = .init(bitPattern: value.bitPattern.byteSwapped)
        }
        return value
    }
}

extension Float64 {
    static func parse(from data: Data, at offset: inout UInt8, littleEndian: Bool = true) -> Self {
        var value: Self = data.object(at: &offset)

        if littleEndian != (UInt64(littleEndian: 1) == 1) {
            value = .init(bitPattern: value.bitPattern.byteSwapped)
        }
        return value
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
