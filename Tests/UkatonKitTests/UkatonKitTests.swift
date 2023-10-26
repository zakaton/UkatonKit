@testable import UkatonKit
import XCTest

let mission: UKMission = .init()

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
            let data: Data = deviceType.rawValue.data
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
            102,
            205,
            0,
            9,
            5,
            86,
            14,
            176,
            251,
            84,
            1,
            202,
            193,
            1,
            0,
        ]
        let pressureData: [UInt8] = [
            98,
            104,
            0,
            0,
            1,
            9,
            4,
            234,
            52,
            117,
            84,
            125,
            237,
            212,
            63,
        ]
        mission.sensorDataManager.parse(quaternionData.data)
        mission.sensorDataManager.deviceType = .rightInsole
        mission.sensorDataManager.parse(pressureData.data)
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
