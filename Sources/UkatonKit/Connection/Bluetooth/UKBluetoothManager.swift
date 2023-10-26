import CoreBluetooth
import Foundation

class UKBluetoothManager: UKConnectionManager {
    let type: UKConnectionType = .bluetooth
    var status: UKConnectionStatus = .notConnected
}
