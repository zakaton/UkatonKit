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
            motion: [
                .quaternion: 40,
            ]
        )
        mission.sensorDataConfigurationsManager.configurations = sensorDataConfigurations

        let serializedConfigurations = mission.sensorDataConfigurationsManager.getSerialization()
        print("serialization: \(serializedConfigurations.bytes)")

        mission.sensorDataConfigurationsManager.configurations = .init()
        mission.sensorDataConfigurationsManager.parse(Data([UInt8](arrayLiteral: 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)))
        print(mission.sensorDataConfigurationsManager.configurations)

        XCTAssertEqual(sensorDataConfigurations, mission.sensorDataConfigurationsManager.configurations, "configurations don't match")
    }

    // MARK: - Sensor Data

    func testParseSensorData() {
        // TODO: - FILL
    }

    // MARK: - Haptics

    func testSerializeHapticsWaveforms() {
        let waveformSerialization = mission.hapticsManager.serialize(waveforms: [.longDoubleSharpTick80, .doubleClick100])
        print(waveformSerialization.bytes)
    }

    func testSerializeHapticsSequence() {
        let sequenceSerialization = mission.hapticsManager.serialize(sequence: [.init(intensity: 1, delay: 20)])
        print(sequenceSerialization.bytes)
    }

    // MARK: - Bluetooth Connection

    func testBluetoothConnection() {
        // TODO: - FILL
    }

    // MARK: - UDP Connection

    func testUdpConnection() {
        // TODO: - FILL
    }
}
