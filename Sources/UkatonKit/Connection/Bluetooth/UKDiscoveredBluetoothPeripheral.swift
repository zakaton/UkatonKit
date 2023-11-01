import CoreBluetooth

public typealias UKBluetoothPeripheralAdvertisementData = [String: Any]

public struct UKDiscoveredBluetoothPeripheral: Identifiable {
    public let peripheral: CBPeripheral
    public let rssi: NSNumber
    public let advertisementData: UKBluetoothPeripheralAdvertisementData
    public let type: UKDeviceType
    public let isConnectedToWifi: Bool
    public let ipAddress: String

    public var id: UUID { self.peripheral.identifier }

    var connectionManager: UKBluetoothConnectionManager? { self.peripheral.delegate as? UKBluetoothConnectionManager }
    public var isConnected: Bool { self.connectionManager != nil }

    init(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: UKBluetoothPeripheralAdvertisementData) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertisementData = advertisementData

        let serviceData = advertisementData["kCBAdvDataServiceData"] as! [CBUUID: Any]
        let rawServiceData = serviceData[UKBluetoothServiceIdentifier.main.uuid] as! Data
        print(rawServiceData)

        var offset: Data.Index = 0
        self.type = .init(rawValue: rawServiceData[offset])!
        offset += 1
        self.isConnectedToWifi = rawServiceData[0] != 0
        offset += 1

        self.ipAddress = rawServiceData.parseString(offset: &offset, until: rawServiceData.count)
    }
}
