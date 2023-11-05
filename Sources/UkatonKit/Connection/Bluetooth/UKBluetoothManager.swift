import CoreBluetooth
import Foundation
import OSLog
import UkatonMacros

// https://stackoverflow.com/questions/55264145/simple-way-to-replace-an-item-in-an-array-if-it-exists-append-it-if-it-doesnt
extension Array {
    mutating func replaceOrAppend(_ item: Element, whereFirstIndex predicate: (Element) -> Bool) {
        if let idx = firstIndex(where: predicate) {
            self[idx] = item
        }
        else {
            append(item)
        }
    }

    mutating func replaceOrAppend<Value>(_ item: Element,
                                         firstMatchingKeyPath keyPath: KeyPath<Element, Value>)
        where Value: Equatable
    {
        let itemValue = item[keyPath: keyPath]
        replaceOrAppend(item, whereFirstIndex: { $0[keyPath: keyPath] == itemValue })
    }
}

@StaticLogger
@Singleton
public class UKBluetoothManager: NSObject, ObservableObject {
    lazy var centralManager: CBCentralManager = .init(delegate: self, queue: .main)

    // MARK: - Scanning

    @Published public var discoveredDevices: [UKDiscoveredBluetoothDevice] = []
    @Published public private(set) var isScanning: Bool = false

    private var shouldScanForDevicesWhenPoweredOn: Bool = false
    public func scanForDevices() {
        if centralManager.state == .poweredOn {
            discoveredDevices.removeAll(where: { $0.mission?.connectionStatus == .notConnected })
            centralManager.scanForPeripherals(withServices: [UKBluetoothServiceIdentifier.main.uuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            isScanning = true
            startTimer()
            logger.debug("scanning for devices...")
        }
        else {
            logger.debug("will scan for devices when centralManager is powered on")
            shouldScanForDevicesWhenPoweredOn = true
        }
    }

    public func stopScanningForDevices() {
        if centralManager.isScanning {
            centralManager.stopScan()
            isScanning = false
            logger.debug("stopped scanning for devices")
        }
        stopTimer()
    }

    public func toggleDeviceScan() {
        if centralManager.isScanning {
            stopScanningForDevices()
        }
        else {
            scanForDevices()
        }
    }

    // MARK: - Check Devices

    var timer: Timer?

    func startTimer() {
        guard timer == nil else {
            logger.warning("timer is already running")
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkDevices), userInfo: nil, repeats: true)
        timer?.tolerance = 0.2
    }

    func stopTimer() {
        guard timer != nil else {
            logger.warning("no timer to stop")
            return
        }

        timer!.invalidate()
        timer = nil
    }

    @objc func checkDevices() {
        discoveredDevices.removeAll(where: {
            $0.mission?.connectionStatus == .notConnected && $0.lastTimeReceivedAdvertisement.timeIntervalSinceNow < -4
        })
    }
}

extension UKBluetoothManager: CBCentralManagerDelegate {
    // MARK: - State

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.debug("centralManager state: \(String(describing: central.state))")
        if central.state == .poweredOn {
            logger.debug("centralManager is powered on")
            if shouldScanForDevicesWhenPoweredOn {
                scanForDevices()
                shouldScanForDevicesWhenPoweredOn = false
            }
        }
    }

    // MARK: - Scanning

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: UKBluetoothPeripheralAdvertisementData, rssi RSSI: NSNumber) {
        if let index = discoveredDevices.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            discoveredDevices[index].rssi = RSSI
            discoveredDevices[index].advertisementData = advertisementData
            discoveredDevices[index].lastTimeReceivedAdvertisement = Date.now
        }
        else {
            discoveredDevices.append(.init(peripheral: peripheral, rssi: RSSI, advertisementData: advertisementData))
        }
    }

    // MARK: - Connection

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let bluetoothConnectionManager = peripheral.delegate as? UKBluetoothConnectionManager {
            bluetoothConnectionManager.onPeripheralConnection()
        }
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let bluetoothConnectionManager = peripheral.delegate as? UKBluetoothConnectionManager {
            bluetoothConnectionManager.onPeripheralDisconnection()
        }
    }
}
