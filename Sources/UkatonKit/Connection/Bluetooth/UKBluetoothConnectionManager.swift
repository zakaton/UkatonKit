import CoreBluetooth
import Foundation

class UKBluetoothConnectionManager: UKConnectionManager {
    // MARK: - UUID

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

    private var characteristics: [CBUUID: CBCharacteristic] = [:]
    

    // MARK: - Device

    private var ukatonPeripheral: CBPeripheral? = nil

    // MARK: - UKConnectionManager

    let type: UKConnectionType = .bluetooth
    var status: UKConnectionStatus = .notConnected
}
