import CoreBluetooth

public typealias UKBluetoothPeripheralAdvertisementData = [String: Any]

public struct UKDiscoveredBluetoothDevice: Identifiable {
    let peripheral: CBPeripheral
    public let rssi: NSNumber
    public let advertisementData: UKBluetoothPeripheralAdvertisementData
    public let type: UKDeviceType
    public let isConnectedToWifi: Bool
    public private(set) var ipAddress: String?

    public var id: UUID { self.peripheral.identifier }

    public var name: String { self.peripheral.name! }
    public var state: CBPeripheralState { self.peripheral.state }
    public var isConnected: Bool { self.state == .connected && self.connectionManager != nil }

    var connectionManager: UKBluetoothConnectionManager? { self.peripheral.delegate as? UKBluetoothConnectionManager }

    init(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: UKBluetoothPeripheralAdvertisementData) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertisementData = advertisementData

        let serviceData = advertisementData["kCBAdvDataServiceData"] as! [CBUUID: Any]
        let rawServiceData = serviceData[UKBluetoothServiceIdentifier.main.uuid] as! Data

        // print(rssi)
        // print(advertisementData)

        var offset: Data.Index = 0
        self.type = .init(rawValue: rawServiceData[offset])!
        offset += 1
        self.isConnectedToWifi = rawServiceData[0] != 0
        offset += 1

        if self.isConnectedToWifi {
            self.ipAddress = rawServiceData.parseString(offset: &offset, until: rawServiceData.count)
        }
    }
}
