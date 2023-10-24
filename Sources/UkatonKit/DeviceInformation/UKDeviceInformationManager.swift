import Foundation
import OSLog
import StaticLogger

@StaticLogger
struct UKDeviceInformationManager {
    // MARK: - Name

    private var name: String? {
        didSet {
            onNameUpdated?(name)
            checkIsFullyInitialized()
        }
    }

    mutating func parseName(data: Data, at offset: inout UInt8, until finalOffset: UInt8) {
        if offset < finalOffset, finalOffset <= data.count {
            let nameDataRange = Data.Index(offset) ..< Data.Index(finalOffset)
            let nameData = data.subdata(in: nameDataRange)
            if let newName = String(data: nameData, encoding: .utf8) {
                Self.logger.debug("new device name \"\(newName)\"")
                name = newName
            } else {
                Self.logger.error("Unable to decode the data as a string.")
            }
        } else {
            let _offset = offset
            Self.logger.error("offset \(_offset)...\(finalOffset) out of range for data \(data.count)")
        }
    }

    mutating func parseName(data: Data) {
        var offset: UInt8 = 0
        parseName(data: data, at: &offset, until: UInt8(data.count))
    }

    // MARK: - DeviceType

    private var type: UKDeviceType? {
        didSet {
            onTypeUpdated?(type)
            checkIsFullyInitialized()
        }
    }

    mutating func parseType(data: Data, at offset: inout UInt8) {
        if offset < data.count {
            let newTypeRawValue = data[Int(offset)]
            offset += 1
            if let newType = UKDeviceType(rawValue: newTypeRawValue) {
                Self.logger.debug("new type \(newType.name)")
                type = newType
            } else {
                Self.logger.error("invalid device type enum \(newTypeRawValue)")
            }
        }
    }

    mutating func parseType(data: Data) {
        var offset: UInt8 = 0
        parseType(data: data, at: &offset)
    }

    // MARK: - Is Fully Initialized?

    private var isFullyInitialized: Bool = false {
        didSet {
            if isFullyInitialized, oldValue != isFullyInitialized {
                Self.logger.debug("Fully Initialized!")
                onFullyInitialized?()
            }
        }
    }

    private mutating func checkIsFullyInitialized() {
        isFullyInitialized = name != nil && type != nil
    }

    // MARK: - Callbacks

    public var onFullyInitialized: (() -> Void)?
    public var onTypeUpdated: ((UKDeviceType?) -> Void)?
    public var onNameUpdated: ((String?) -> Void)?

    // MARK: - Reset

    public mutating func reset() {
        logger.debug("resetting")
        name = nil
        type = nil
    }
}
