import CoreBluetooth

extension CBUUID {
    convenience init(ukString: String) {
        self.init(string: "5691eddf-\(ukString)-4420-b7a5-bb8751ab5181")
    }
}

enum UKServiceUUID {
    static let main: CBUUID = .init(ukString: "0000")
    static let uuids: [CBUUID] = [main]
}

enum UKCharacteristicUUID {
    static let batteryLevel: CBUUID = .init(string: "0x2A19")

    static let deviceType: CBUUID = .init(ukString: "3001")

    static let deviceName: CBUUID = .init(ukString: "4001")

    static let motionCalibration: CBUUID = .init(ukString: "5001")

    static let sensorDataConfiguration: CBUUID = .init(ukString: "6001")
    static let sensorData: CBUUID = .init(ukString: "6002")

    static let wifiSSID: CBUUID = .init(ukString: "7001")
    static let wifiPassword: CBUUID = .init(ukString: "7002")
    static let wifiConnect: CBUUID = .init(ukString: "7003")
    static let wifiIsConnected: CBUUID = .init(ukString: "7004")
    static let wifiIPAddress: CBUUID = .init(ukString: "7005")

    static let haptics: CBUUID = .init(ukString: "d000")

    static let uuids: [CBUUID] = [
    ]
}
