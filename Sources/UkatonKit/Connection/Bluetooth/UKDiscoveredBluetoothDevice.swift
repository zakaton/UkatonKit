import CoreBluetooth

public typealias UKBluetoothPeripheralAdvertisementData = [String: Any]

public struct UKDiscoveredBluetoothDevice: Identifiable {
    let peripheral: CBPeripheral
    public internal(set) var rssi: NSNumber
    var advertisementData: UKBluetoothPeripheralAdvertisementData? {
        didSet {
            guard let advertisementData else { return }

            let serviceData = advertisementData["kCBAdvDataServiceData"] as! [CBUUID: Any]
            let rawServiceData = serviceData[UKBluetoothServiceIdentifier.main.uuid] as! Data

            self.timestamp = advertisementData["kCBAdvDataTimestamp"] as! Double

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

    public private(set) var type: UKDeviceType?
    public private(set) var isConnectedToWifi: Bool = false
    public private(set) var timestamp: Double = .nan {
        didSet {
            self.timestampDifference_ms = (self.timestamp - oldValue) * 1000
        }
    }

    public private(set) var timestampDifference_ms: Double = .nan

    public private(set) var ipAddress: String?

    public var id: UUID { self.peripheral.identifier }

    public var name: String { self.peripheral.name! }
    public var state: CBPeripheralState { self.peripheral.state }
    public var isConnected: Bool { self.state == .connected && self.connectionManager != nil }

    var connectionManager: UKBluetoothConnectionManager? { self.peripheral.delegate as? UKBluetoothConnectionManager }

    init(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: UKBluetoothPeripheralAdvertisementData) {
        self.peripheral = peripheral
        self.rssi = rssi
        defer {
            self.advertisementData = advertisementData
        }
    }
}
