import Foundation

// MARK: - Number to Data

extension Data {
    func parse<T>(at offset: inout Data.Index) -> T {
        let size = MemoryLayout<T>.size
        let value = subdata(in: Data.Index(offset) ..< self.index(Data.Index(offset), offsetBy: size))
            .withUnsafeBytes { $0.load(as: T.self) }
        offset += size
        return value
    }
}

extension FixedWidthInteger {
    static func parse(from data: Data, at offset: inout Data.Index, littleEndian: Bool = true) -> Self {
        let value: Self = data.parse(at: &offset)
        return littleEndian ? value.littleEndian : value.bigEndian
    }
}

extension Float32 {
    static func parse(from data: Data, at offset: inout Data.Index, littleEndian: Bool = true) -> Self {
        var value: Self = data.parse(at: &offset)

        if littleEndian != (UInt32(littleEndian: 1) == 1) {
            value = .init(bitPattern: value.bitPattern.byteSwapped)
        }
        return value
    }
}

extension Float64 {
    static func parse(from data: Data, at offset: inout Data.Index, littleEndian: Bool = true) -> Self {
        var value: Self = data.parse(at: &offset)

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

// MARK: - Data to String

extension Data {
    func parseString(offset: inout Data.Index, until finalOffset: Data.Index) -> String {
        defer {
            offset = finalOffset
        }
        guard offset < finalOffset, finalOffset <= count else {
            return ""
        }

        let nameDataRange = Data.Index(offset) ..< Data.Index(finalOffset)
        let nameData = subdata(in: nameDataRange)
        guard let newName = String(data: nameData, encoding: .ascii) else {
            return ""
        }
        return newName
    }
}

// MARK: - String to Data

extension String {
    var data: Data {
        return self.data(using: .ascii)!
    }
}

// MARK: - Bool to Data

extension Bool {
    var number: UInt8 {
        self ? 1 : 0
    }

    var data: Data {
        return .init([self.number])
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
