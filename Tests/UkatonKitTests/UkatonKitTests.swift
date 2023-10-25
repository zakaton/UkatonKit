@testable import UkatonKit
import XCTest

let mission: UKBaseMission = .init()

final class UkatonKitTests: XCTestCase {
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

    func testParseDeviceInformation() {
        testParseDeviceName()
        testParseDeviceType()
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
        let quaternionData: [UInt8] = [
            166,
            119,
            0,
            9,
            5,
            128,
            13,
            203,
            250,
            152,
            2,
            182,
            193,
            1,
            0,
        ]
        let pressureData: [UInt8] = [
            74,
            175,
            0,
            0,
            1,
            17,
            0,
            107,
            0,
            0,
            0,
            79,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        ]
        mission.sensorDataManager.parse(quaternionData.data)
        mission.sensorDataManager.deviceType = .leftInsole
        mission.sensorDataManager.parse(pressureData.data)
        print(mission.sensorDataManager.motion.quaternion)
        print(mission.sensorDataManager.pressure.pressureValues)
    }

    // MARK: - Motion Calibration Data

    func testMotionCalibrationData() {
        let motionCalibrationData: UKMotionCalibrationData = [
            .accelerometer: .high,
            .gyroscope: .high,
            .magnetometer: .high,
            .quaternion: .high,
        ]
        let rawMotionCalibrationData = UKMotionCalibrationType.allCases.map { motionCalibrationData[$0]!.rawValue }
        print(rawMotionCalibrationData)
        mission.motionCalibrationDataManager.parse(rawMotionCalibrationData.data)
        print(mission.motionCalibrationDataManager.calibration)
        XCTAssertEqual(mission.motionCalibrationDataManager.calibration, motionCalibrationData, "calibrations don't match")
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
