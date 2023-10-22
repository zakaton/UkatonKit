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

// MARK: - Data to Number

extension Numeric {
    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<Self>.size)
    }
}
