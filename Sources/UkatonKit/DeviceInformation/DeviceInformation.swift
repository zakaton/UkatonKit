import Foundation
import OSLog
import StaticLogger

@StaticLogger
public struct DeviceInformation {
    public private(set) var name: String? = nil {
        didSet {
            checkIsFullyInitialized()
        }
    }

    public private(set) var type: DeviceType? = nil {
        didSet {
            checkIsFullyInitialized()
        }
    }

    mutating func parseName(data: inout Data, offset: inout UInt8, finalOffset: UInt8) {
        if offset >= 0, offset < finalOffset, finalOffset < data.count {
            let nameDataRange = Data.Index(offset) ..< Data.Index(finalOffset)
            let nameData = data.subdata(in: nameDataRange)
            if let newName = String(data: nameData, encoding: .utf8) {
                name = newName
            } else {
                Self.logger.warning("Unable to decode the data as a string.")
            }
        }
    }

    mutating func parseType(data: inout Data, offset: inout UInt8) {
        if offset < data.count {
            type = .init(rawValue: data[Int(offset)])
            offset += 1
        }
    }

    private var isFullyInitialized: Bool = false {
        didSet {
            if isFullyInitialized, oldValue != isFullyInitialized {
                // FILL - call callback
            }
        }
    }

    private mutating func checkIsFullyInitialized() {
        isFullyInitialized = name != nil && type != nil
    }

    public mutating func reset() {
        name = nil
        type = nil
    }
}
