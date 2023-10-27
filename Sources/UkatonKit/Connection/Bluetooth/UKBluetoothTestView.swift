import CoreBluetooth
import SwiftUI

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}

class BluetoothViewModel: NSObject, ObservableObject {
    enum ConnectionState: String {
        case notConnected = "not connected"
        case connected

        var name: String { rawValue }
    }

    @Published var connectionState: ConnectionState = .notConnected

    @Published var lastTimeReceivedData: Int64 = 0

    static let shared: BluetoothViewModel = .init()

    static func generateUUID(_ value: String) -> CBUUID {
        .init(string: "5691eddf-\(value)-4420-b7a5-bb8751ab5181")
    }

    enum ServiceUUID {
        static let main: CBUUID = generateUUID("0000")

        static let uuids: [CBUUID] = [main]
    }

    enum CharacteristicUUID {
        static let sensorDataConfiguration: CBUUID = generateUUID("6001")
        static let sensorData: CBUUID = generateUUID("6002")

        static let uuids: [CBUUID] = [sensorDataConfiguration, sensorData]
    }

    var characteristics: [CBUUID: CBCharacteristic] = [:]

    private var centralManager: CBCentralManager!
    private var ukatonPeripheral: CBPeripheral? = nil
    @Published var peripheralNames: [String] = []

    override init() {
        super.init()
        // self.centralManager = .init(delegate: self, queue: .main)
    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: ServiceUUID.uuids)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if ukatonPeripheral == nil {
            ukatonPeripheral = peripheral
            centralManager.connect(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(ServiceUUID.uuids)
        print("connected")
        connectionState = .connected
        centralManager.stopScan()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
        connectionState = .notConnected
    }
}

extension BluetoothViewModel: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("discovered services")
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(CharacteristicUUID.uuids, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("discovered characteristics")
        for characteristic in service.characteristics ?? [] {
            characteristics[characteristic.uuid] = characteristic
            print(characteristic.uuid)
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }

        if let sensorDataConfigurationCharacteristic = characteristics[CharacteristicUUID.sensorDataConfiguration] {
            let sensorDataConfiguration: [UInt8] = [0, 3, 5, 20, 0]
            peripheral.writeValue(Data(sensorDataConfiguration), for: sensorDataConfigurationCharacteristic, type: .withResponse)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("updated notificaton state for \(characteristic.uuid)")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        lastTimeReceivedData = Date().currentTimeMillis()
    }
}

struct BluetoothTestView: View {
    @StateObject private var bluetoothViewModel: BluetoothViewModel = .shared

    var body: some View {
        NavigationStack {
            List {
                Text(bluetoothViewModel.connectionState.name)
                Text(String(bluetoothViewModel.lastTimeReceivedData))
            }
            .navigationTitle("Ukaton Mission")
        }
    }
}

#Preview {
    BluetoothTestView()
        .frame(maxWidth: 300)
}
