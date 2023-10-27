import CoreBluetooth

typealias UKBluetoothPeripheralAdvertisementData = [String: Any]

struct UKDiscoveredBluetoothPeripheral {
    let peripheral: CBPeripheral
    let RSSI: NSNumber
    let advertisementData: UKBluetoothPeripheralAdvertisementData
}
