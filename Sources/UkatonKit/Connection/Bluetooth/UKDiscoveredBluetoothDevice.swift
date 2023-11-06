import Combine
import CoreBluetooth
import OSLog
import UkatonMacros

public typealias UKBluetoothPeripheralAdvertisementData = [String: Any]

@StaticLogger
public struct UKDiscoveredBluetoothDevice {
    public static let none = UKDiscoveredBluetoothDevice()

    // MARK: - Stored Properties

    private(set) var peripheral: CBPeripheral?
    public internal(set) var rssi: NSNumber?
    var lastTimeInteracted: Date = .now

    // MARK: - Peripheral Getters

    public var name: String?
    public private(set) var mission: UKMission?

    // MARK: - Parsing Advertisement Data

    var advertisementData: UKBluetoothPeripheralAdvertisementData? {
        didSet {
            guard let advertisementData else { return }

            let serviceData = advertisementData["kCBAdvDataServiceData"] as! [CBUUID: Any]
            let rawServiceData = serviceData[UKBluetoothServiceIdentifier.main.uuid] as! Data

            self.timestamp = advertisementData["kCBAdvDataTimestamp"] as! Double

            var offset: Data.Index = 0
            self.type = .init(rawValue: rawServiceData[offset])!
            offset += 1
            self.isConnectedToWifi = rawServiceData[offset] != 0
            offset += 1

            if self.isConnectedToWifi, rawServiceData.count > 2 {
                var ipAddressBytes: [UInt8] = []
                for _ in 0 ..< 4 {
                    ipAddressBytes.append(rawServiceData.parse(at: &offset))
                }
                self.ipAddress = ipAddressBytes.map { String($0) }.joined(separator: ".")
            }
        }
    }

    // MARK: - Parsed Properties

    public private(set) var type: UKDeviceType?
    public private(set) var isConnectedToWifi: Bool = false
    public private(set) var ipAddress: String?
    public private(set) var timestamp: Double = .nan {
        didSet {
            self.timestampDifference_ms = (self.timestamp - oldValue) * 1000
        }
    }

    public private(set) var timestampDifference_ms: Double = .nan

    // MARK: - init

    init() {}

    init(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: UKBluetoothPeripheralAdvertisementData) {
        self.peripheral = peripheral
        defer {
            self.onAdvertisementUpdate(peripheral: peripheral, rssi: rssi, advertisementData: advertisementData)
        }
    }

    mutating func onAdvertisementUpdate(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: UKBluetoothPeripheralAdvertisementData) {
        self.name = peripheral.name
        self.rssi = rssi
        self.advertisementData = advertisementData
        self.lastTimeInteracted = Date.now
    }

    // MARK: - connect

    public mutating func connect(type connectionType: UKConnectionType) {
        if self.mission == nil {
            self.mission = .init(discoveredBluetoothDevice: self)
        }
        self.mission!.connect(type: connectionType)
    }

    public mutating func disconnect() {
        if self.mission != nil {
            self.lastTimeInteracted = Date.now
            self.mission!.disconnect()
        }
    }
}

extension UKDiscoveredBluetoothDevice: Identifiable, Hashable {
    public var id: UUID? { self.peripheral?.identifier }
    public func hash(into hasher: inout Hasher) { hasher.combine(self.id) }

    public static func == (lhs: UKDiscoveredBluetoothDevice, rhs: UKDiscoveredBluetoothDevice) -> Bool {
        lhs.id == rhs.id
    }
}
