import CoreBluetooth

public typealias UKBluetoothPeripheralAdvertisementData = [String: Any]

public struct UKDiscoveredBluetoothPeripheral: Identifiable {
    public let peripheral: CBPeripheral
    public let RSSI: NSNumber
    public let advertisementData: UKBluetoothPeripheralAdvertisementData
    public var id: UUID { self.peripheral.identifier }
}
