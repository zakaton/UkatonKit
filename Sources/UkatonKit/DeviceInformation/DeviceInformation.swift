import Foundation
import OSLog

public struct DeviceInformation {
    static let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: Self.self))
    var logger: Logger { Self.logger }

    public private(set) var name: String? {
        didSet {
            checkIsFullyInitialized()
        }
    }

    public private(set) var deviceType: DeviceType? {
        didSet {
            checkIsFullyInitialized()
        }
    }

    mutating func parseName(data: Data, offset: inout UInt8, finalOffset: UInt8) {
        if offset >= 0, offset < finalOffset, finalOffset < data.count {
            let nameDataRange = Data.Index(offset) ..< Data.Index(finalOffset)
            let nameData = data.subdata(in: nameDataRange)
            if let newName = String(data: nameData, encoding: .utf8) {
                logger.debug("new name \(newName)")
                name = newName
            } else {
                logger.warning("Unable to decode the data as a string.")
            }
        }
    }

    mutating func parseType(data: Data, offset: inout UInt8) {
        if offset < data.count {
            if let newDeviceType = DeviceType(rawValue: data[Int(offset)]) {
                logger.debug("new deviceType \(String(describing: newDeviceType))")
                deviceType = newDeviceType
            } else {
                logger.warning("invalid device type enum")
            }
            offset += 1
        }
    }

    private var isFullyInitialized: Bool = false {
        didSet {
            if isFullyInitialized, oldValue != isFullyInitialized {
                logger.debug("Fully Initialized!")
                onFullyInitialized?()
            }
        }
    }

    private mutating func checkIsFullyInitialized() {
        isFullyInitialized = name != nil && deviceType != nil
    }

    public var onFullyInitialized: (() -> Void)?

    public mutating func reset() {
        logger.debug("resetting")
        name = nil
        deviceType = nil
    }
}
