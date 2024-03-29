import CoreBluetooth
import Foundation
import OSLog
import UkatonMacros

@StaticLogger
class UKBluetoothConnectionManager: NSObject, UKConnectionManager, ObservableObject, CBPeripheralDelegate {
    var id: String { peripheral?.identifier.uuidString ?? "" }

    // MARK: - UKConnectionManager

    static let allowedMessageTypes: [UKConnectionMessageType] = UKConnectionMessageType.allCases

    var onStatusUpdated: ((UKConnectionStatus) -> Void)?

    let type: UKConnectionType = .bluetooth
    var status: UKConnectionStatus = .notConnected {
        didSet {
            if status != oldValue {
                onStatusUpdated?(status)
            }
        }
    }

    // MARK: - Messaging

    var onMessageReceived: ((UKConnectionMessageType, Data, inout Data.Index) -> Void)?

    func sendMessage(type messageType: UKConnectionMessageType, data: Data) throws {
        guard let peripheral else {
            throw UKConnectionManagerMessageError.bluetoothError("peripheral not defined")
        }

        guard let characteristicIdentifier: UKBluetoothCharacteristicIdentifier = .init(connectionMessageType: messageType) else {
            throw UKConnectionManagerMessageError.bluetoothError("no characteristicIdentifier defined for messageType \(messageType.name)")
        }

        guard let characteristic = characteristics[characteristicIdentifier] else {
            throw UKConnectionManagerMessageError.bluetoothError("no characteristic defined for messageType \(messageType.name)")
        }

        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    // MARK: - UKBluetoothManager

    var centralManager: CBCentralManager {
        UKBluetoothManager.shared.centralManager
    }

    // MARK: - Characteristics

    private var characteristics: [UKBluetoothCharacteristicIdentifier: CBCharacteristic] = [:]

    // MARK: - Peripheral Device

    weak var peripheral: CBPeripheral? = nil {
        willSet {
            if let peripheral {
                peripheral.delegate = nil
            }
        }
        didSet {
            if let peripheral {
                peripheral.delegate = self
            }
        }
    }

    // MARK: - Initializer

    init(peripheral: CBPeripheral) {
        super.init()

        defer {
            self.peripheral = peripheral
        }
    }

    // MARK: - Connection

    func connect() {
        guard let peripheral, peripheral.state == .disconnected else {
            logger.error("unable to connect, peripheral is in state \(String(describing: self.peripheral!.state))")
            return
        }

        status = .connecting

        centralManager.connect(peripheral)
    }

    func disconnect() {
        guard let peripheral, peripheral.state == .connected || peripheral.state == .connecting else {
            logger.error("unable to disconnect, peripheral is in state \(String(describing: self.peripheral!.state))")
            status = .notConnected
            return
        }

        status = .disconnecting

        centralManager.cancelPeripheralConnection(peripheral)
    }

    // MARK: - Connection callbacks

    func onPeripheralConnection() {
        logger.debug("connected to peripheral")
        peripheral?.discoverServices(UKBluetoothServiceIdentifier.allUUIDs)
    }

    func onPeripheralDisconnection() {
        logger.debug("disconnected from peripheral")
        status = .notConnected
    }

    // MARK: - Service Discovery

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            logger.error("error when discovering services: \(error.localizedDescription)")
            return
        }

        peripheral.services?.forEach { service in
            if let serviceIdentifier = UKBluetoothServiceIdentifier(service: service) {
                onDiscovered(service: service, withIdentifier: serviceIdentifier)
            }
        }
    }

    func onDiscovered(service: CBService, withIdentifier serviceIdentifier: UKBluetoothServiceIdentifier) {
        logger.debug("discovered services for \(serviceIdentifier.name)")
        peripheral!.discoverCharacteristics(serviceIdentifier.characteristicUUIDs, for: service)
    }

    // MARK: - Characteristic Discovery

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let serviceIdentifier = UKBluetoothServiceIdentifier(service: service) {
            if let error {
                logger.error("error when discovering characteristics for \(serviceIdentifier.name): \(error.localizedDescription)")
                return
            }

            logger.debug("discovered characteristics for \(serviceIdentifier.name)")
            service.characteristics?.forEach { characteristic in
                if let characteristicIdentifier = UKBluetoothCharacteristicIdentifier(characteristic: characteristic) {
                    onDiscovered(characteristic: characteristic, withIdentifier: characteristicIdentifier)
                }
            }

            if serviceIdentifier == .main {
                status = .connected
            }
        }
    }

    func onDiscovered(characteristic: CBCharacteristic, withIdentifier characteristicIdentifier: UKBluetoothCharacteristicIdentifier) {
        logger.debug("discovered characteristic \(characteristicIdentifier.name)")
        characteristics[characteristicIdentifier] = characteristic
        if characteristic.properties.contains(.notify), characteristicIdentifier.enableNotificationsOnConnection {
            peripheral!.setNotifyValue(true, for: characteristic)
        }
        if characteristic.properties.contains(.read), characteristicIdentifier.readOnConnection {
            peripheral!.readValue(for: characteristic)
        }
    }

    // MARK: - Notifications

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let characteristicIdentifier = UKBluetoothCharacteristicIdentifier(characteristic: characteristic) {
            if let error {
                logger.error("error updating notification state for characteristic \(characteristicIdentifier.name) \(error.localizedDescription)")
                return
            }

            logger.debug("updated notification state for characteristic \(characteristicIdentifier.name): \(characteristic.isNotifying)")
        }
    }

    // MARK: - Read Values

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let characteristicIdentifier = UKBluetoothCharacteristicIdentifier(characteristic: characteristic) {
            if let error {
                logger.error("error reading value for characteristic \(characteristicIdentifier.name) \(error.localizedDescription)")
                return
            }

            if let value = characteristic.value {
                onReceived(data: value, from: characteristic, withIdentifier: characteristicIdentifier)
            }
            else {
                logger.error("unable to read data from characteristic \(characteristicIdentifier.name)")
            }
        }
    }

    func onReceived(data: Data, from characteristic: CBCharacteristic, withIdentifier characteristicIdentifier: UKBluetoothCharacteristicIdentifier) {
        logger.debug("received \(data.count) bytes from characteristic \(characteristicIdentifier.name)")
        onMessageReceived(type: characteristicIdentifier.connectionMessageType, data: data)
    }

    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        if let name = peripheral.name {
            logger.debug("peripheral name changed to \(name)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let characteristicIdentifier: UKBluetoothCharacteristicIdentifier = .init(characteristic: characteristic) {
            logger.debug("didWriteValueFor \(characteristicIdentifier.name)")
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        let rssiInt = RSSI.intValue
        logger.debug("received rssi \(rssiInt.description)")
        onMessageReceived(type: .bluetoothRSSI, data: rssiInt.data)
    }
}
