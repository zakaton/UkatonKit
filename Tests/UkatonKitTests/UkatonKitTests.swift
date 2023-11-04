@testable import UkatonKit
import XCTest

let mission: UKMission = .init()

final class UkatonKitTests: XCTestCase {
    // MARK: - Device Informaton

    func testParseDeviceName() {
        let deviceName = "My Ukaton Mission"
        let data: Data = .init(deviceName.utf8)
        mission.parseName(data: data)
        XCTAssertEqual(deviceName, mission.name, "names don't match")
    }

    func testParseDeviceType() {
        UKDeviceType.allCases.forEach { deviceType in
            let data: Data = deviceType.rawValue.data
            mission.parseDeviceType(data: data)
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
        mission.sensorDataConfigurations.configurations = sensorDataConfigurations

        let serializedConfigurations = mission.sensorDataConfigurations.getSerialization()
        print("serialization: \(serializedConfigurations.bytes)")

        mission.sensorDataConfigurations.configurations = .init()
        mission.sensorDataConfigurations.parse(Data([UInt8](arrayLiteral: 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)))
        print(mission.sensorDataConfigurations.configurations)

        XCTAssertEqual(sensorDataConfigurations, mission.sensorDataConfigurations.configurations, "configurations don't match")
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
        mission.sensorData.parse(quaternionData.data)
        mission.sensorData.deviceType = .rightInsole
        mission.sensorData.parse(pressureData.data)
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
        mission.motionCalibrationData.parse(rawMotionCalibrationData.data)
        print(mission.motionCalibrationData.calibration)
        XCTAssertEqual(mission.motionCalibrationData.calibration, motionCalibrationData, "calibrations don't match")
    }

    // MARK: - Haptics

    func testSerializeHapticsWaveforms() {
        let waveformSerialization = mission.serializeHaptics(waveforms: [.longDoubleSharpTick80, .doubleClick100])
        print(waveformSerialization.bytes)
    }

    func testSerializeHapticsSequence() {
        let sequenceSerialization = mission.serializeHaptics(sequence: [.init(intensity: 1, delay: 20)])
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
