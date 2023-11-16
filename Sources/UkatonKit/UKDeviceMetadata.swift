public protocol UKDeviceMetadata {
    var name: String { get }
    var deviceType: UKDeviceType { get }
}

extension UKMission: UKDeviceMetadata {}

extension UKDiscoveredBluetoothDevice: UKDeviceMetadata {}
