import CoreBluetooth
import Foundation
import OSLog
import UkatonMacros

@StaticLogger
class UKBluetoothConnectionManager: NSObject, UKConnectionManager, ObservableObject, CBPeripheralDelegate {
    // MARK: - UKConnectionManager Protocol

    let type: UKConnectionType = .bluetooth
    var status: UKConnectionStatus = .notConnected

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
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
}
