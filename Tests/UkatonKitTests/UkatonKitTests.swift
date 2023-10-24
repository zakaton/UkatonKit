@testable import UkatonKit
import XCTest

final class UkatonKitTests: XCTestCase {
    let mission: UKBaseMission = .init()

    // MARK: - Device Informaton

    func testParseDeviceName() {
        let deviceName = "My Ukaton Mission"
        let data: Data = .init(deviceName.utf8)
        mission.deviceInformationManager.parseName(data: data)
        XCTAssertEqual(deviceName, mission.deviceName, "names don't match")
    }

    func testParseDeviceType() {
        UKDeviceType.allCases.forEach { deviceType in
            let data: Data = .init([deviceType.rawValue])
            mission.deviceInformationManager.parseType(data: data)
            XCTAssertEqual(deviceType, mission.deviceType, "types don't match")
        }
    }

    // MARK: - Sensor Data Configuration

    func testSensorDataConfiguration() {
        let sensorDataConfigurations: UKSensorDataConfigurations = .init(
            motion: [.quaternion: 40],
            pressure: [.centerOfMass: 40]
        )
        mission.sensorDataConfigurationsManager.configurations = sensorDataConfigurations
        let serializedSensorDataConfiguration = mission.sensorDataConfigurationsManager.getSerialization()
        serializedSensorDataConfiguration.forEach { value in print(value) }
        XCTAssertEqual(sensorDataConfigurations, mission.sensorDataConfigurationsManager.configurations, "configurations don't match")
    }

    // MARK: - Sensor Data

    func testParseSensorData() {
        // TODO: - FILL
    }

    // MARK: - Haptics

    func testSerializeHapticsWaveforms() {
        // TODO: - FILL
    }

    func testSerializeHapticsSequence() {
        // TODO: - FILL
    }

    // MARK: - Bluetooth Connection

    func testConnectBluetooth() {
        // TODO: - FILL
    }

    // MARK: - UDP Connection

    func testConnectUdp() {
        // TODO: - FILL
    }
}
