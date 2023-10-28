import Foundation
import OSLog
import UkatonMacros

@StaticLogger
struct UKDeviceInformationManager {
    // MARK: - Name

    private var name: String? {
        didSet {
            onNameUpdated?(name)
            checkIsFullyInitialized()
        }
    }

    public var onNameUpdated: ((String?) -> Void)?

    mutating func parseName(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newName = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new device name \"\(newName)\"")
        name = newName
    }

    mutating func parseName(data: Data) {
        var offset: Data.Index = 0
        parseName(data: data, at: &offset, until: data.count)
    }

    // MARK: - DeviceType

    private var type: UKDeviceType? {
        didSet {
            onTypeUpdated?(type)
            checkIsFullyInitialized()
        }
    }

    public var onTypeUpdated: ((UKDeviceType?) -> Void)?

    mutating func parseType(data: Data, at offset: inout Data.Index) {
        if offset < data.count {
            let newTypeRawValue: UKDeviceType.RawValue = .parse(from: data, at: &offset)
            if let newType = UKDeviceType(rawValue: newTypeRawValue) {
                logger.debug("new type \(newType.name)")
                type = newType
            } else {
                logger.error("invalid device type enum \(newTypeRawValue)")
            }
        }
    }

    mutating func parseType(data: Data) {
        var offset: Data.Index = 0
        parseType(data: data, at: &offset)
    }

    // MARK: - Is Fully Initialized?

    private var isFullyInitialized: Bool = false {
        didSet {
            if isFullyInitialized, oldValue != isFullyInitialized {
                logger.debug("Fully Initialized!")
            }
            onIsFullyInitialized?(isFullyInitialized)
        }
    }

    public var onIsFullyInitialized: ((Bool) -> Void)?

    private mutating func checkIsFullyInitialized() {
        isFullyInitialized = name != nil && type != nil
    }

    // MARK: - Reset

    public mutating func reset() {
        logger.debug("resetting")
        name = nil
        type = nil
    }
}
