import CoreBluetooth
import Foundation
import UkatonMacros

class UKBluetoothManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        self.centralManager = .init(delegate: self, queue: .main)
    }
}
