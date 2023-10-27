import CoreBluetooth
import Foundation
import OSLog
import UkatonMacros

@StaticLogger
class UKBluetoothConnectionManager: NSObject, UKConnectionManager, ObservableObject, CBPeripheralDelegate {
    var onDeviceType: ((Data) -> Void)?

    // MARK: - UKConnectionManager Protocol

    let type: UKConnectionType = .bluetooth
    var status: UKConnectionStatus {
        switch peripheral?.state {
        case nil, .disconnected, .connecting:
            .notConnected
        case .connected, .disconnecting:
            .connected
        case .some:
            .notConnected
        }
    }

    // MARK: - UKBluetoothManager

    var centralManager: CBCentralManager {
        UKBluetoothManager.shared.centralManager
    }

    // MARK: - Characteristics

    private var characteristics: [CBUUID: CBCharacteristic] = [:]

    // MARK: - Peripheral Device

    var peripheral: CBPeripheral? = nil {
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

        centralManager.connect(peripheral)
    }

    func disconnect() {
        guard let peripheral, peripheral.state == .connected else {
            logger.error("unable to disconnect, peripheral is in state \(String(describing: self.peripheral!.state))")
            return
        }

        centralManager.cancelPeripheralConnection(peripheral)
    }

    // MARK: - Connection callbacks

    func onConnection() {
        logger.debug("connected")
        peripheral?.discoverServices(UKBluetoothServiceIdentifier.allUUIDs)
    }

    func onDisconnection() {
        logger.debug("disconnected")
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
        }
    }

    func onDiscovered(characteristic: CBCharacteristic, withIdentifier serviceIdentifier: UKBluetoothCharacteristicIdentifier) {
        logger.debug("discovered characteristic \(serviceIdentifier.name)")
        if characteristic.properties.contains(.notify) {
            peripheral!.setNotifyValue(true, for: characteristic)
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

        switch characteristicIdentifier {
        case .deviceType:
            onDeviceType?(data)
        default:
            logger.error("uncaught data handler for characteristic \(characteristicIdentifier.name)")
        }
    }
}
