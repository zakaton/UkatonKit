import CoreBluetooth
import OSLog
import UkatonMacros

public typealias UKBluetoothPeripheralAdvertisementData = [String: Any]

@StaticLogger
public struct UKDiscoveredBluetoothDevice {
    // MARK: - Stored Properties

    let peripheral: CBPeripheral
    public internal(set) var rssi: NSNumber

    // MARK: - Peripheral Getters

    public var name: String { self.peripheral.name! }
    public var mission: UKMission?

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
            self.isConnectedToWifi = rawServiceData[0] != 0
            offset += 1

            if self.isConnectedToWifi {
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

    init(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: UKBluetoothPeripheralAdvertisementData) {
        self.peripheral = peripheral
        self.rssi = rssi
        defer {
            self.advertisementData = advertisementData
        }
    }

    // MARK: - connect

    func createConnectionManager(type connectionType: UKConnectionType) -> any UKConnectionManager {
        var _connectionType = connectionType
        if connectionType.requiresWifi, !self.isConnectedToWifi || self.ipAddress != nil {
            logger.warning("device is not connected to wifi - defaulting to bluetooth")
            _connectionType = .bluetooth
        }

        return switch _connectionType {
        case .bluetooth:
            UKBluetoothConnectionManager(peripheral: self.peripheral)
        case .udp:
            UKUdpConnectionManager(ipAddress: self.ipAddress!)
        }
    }

    public mutating func connect(type connectionType: UKConnectionType) {
        if self.mission == nil {
            self.mission = .init(discoveredBluetoothDevice: self, connectionType: connectionType)
        }
    }
}

extension UKDiscoveredBluetoothDevice: Identifiable, Hashable {
    public var id: UUID { self.peripheral.identifier }
    public func hash(into hasher: inout Hasher) { hasher.combine(self.id) }

    public static func == (lhs: UKDiscoveredBluetoothDevice, rhs: UKDiscoveredBluetoothDevice) -> Bool {
        lhs.id == rhs.id
    }
}
