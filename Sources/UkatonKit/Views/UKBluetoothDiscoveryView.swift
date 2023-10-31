import SwiftUI

// TODO: - button to start/stop for devices
// TODO: - display list of device names

struct UKBluetoothDiscoveryView: View {
    @ObservedObject private var bluetoothManager: UKBluetoothManager = .shared
    var body: some View {
        NavigationStack {
            List {
                ForEach(bluetoothManager.discoveredPeripherals) { _ in
                    Text("LOL")
                }
                Text(bluetoothManager.isScanning ? "scanning" : "not scanning")

                Button {
                    bluetoothManager.toggleDeviceScan()
                } label: {
                    Text(bluetoothManager.isScanning ? "stop scanning" : "scan")
                }
            }
            .navigationTitle("Ukaton Mission")
        }
    }
}

#Preview {
    UKBluetoothDiscoveryView()
        .frame(maxWidth: 300, minHeight: 300)
}
