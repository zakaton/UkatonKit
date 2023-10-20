import Foundation

public struct DeviceInformation {
    public private(set) var name: String? = nil {
        willSet {}
    }

    public private(set) var type: DeviceType? = nil {
        willSet {}
    }

    func parseDeviceName() {}
    func parseDeviceType() {}

    private var isFullyInitialized: Bool = false
    private mutating func checkIsFullyInitialized() {
        if !isFullyInitialized {
            isFullyInitialized = name != nil && type != nil
        }
    }

    public mutating func reset() {
        self = Self()
    }
}
