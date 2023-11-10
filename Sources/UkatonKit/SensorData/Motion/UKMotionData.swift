import Combine
import Foundation
import OSLog
import simd
import Spatial
import UkatonMacros

extension BinaryFloatingPoint {
    var degreesToRadians: Self {
        self * .pi / 180
    }
}

public typealias Quaternion = simd_quatd
public extension Quaternion {
    var string: String {
        .init(format: "w: %5.3f, x: %5.3f, y: %5.3f, z: %5.3f", vector.w, vector.x, vector.y, vector.z)
    }
}

public extension Rotation3D {
    var string: String {
        let euler = eulerAngles(order: .zxy)
        return .init(format: "p: %6.3f, y: %6.3f, r: %6.3f", euler.angles.x, euler.angles.y, euler.angles.z)
    }
}

public extension Vector3D {
    var string: String {
        .init(format: "x: %6.3f, y: %6.3f, z: %6.3f", x, y, z)
    }
}

@StaticLogger
public struct UKMotionData: UKSensorDataComponent {
    // MARK: - Device Type

    var deviceType: UKDeviceType? = nil

    // MARK: - Data Scalar

    typealias Scalars = [UKMotionDataType: Double]
    static let scalars: Scalars = [
        .acceleration: pow(2.0, -8.0),
        .gravity: pow(2.0, -8.0),
        .linearAcceleration: pow(2.0, -8.0),
        .rotationRate: pow(2.0, -9.0),
        .magnetometer: pow(2.0, -4.0),
        .quaternion: pow(2.0, -14.0)
    ]
    var scalars: Scalars { Self.scalars }

    // MARK: - Data

    public private(set) var acceleration: Vector3D = .init()
    public private(set) var gravity: Vector3D = .init()
    public private(set) var linearAcceleration: Vector3D = .init()
    public private(set) var rotationRate: Rotation3D = .init()
    public private(set) var magnetometer: Vector3D = .init()
    public private(set) var quaternion: Quaternion = .init()
    public private(set) var rotation: Rotation3D = .init()

    public private(set) var timestamps: [UKMotionDataType: UKTimestamp] = .zero

    // MARK: - PassthroughSubjects

    public let accelerationSubject = PassthroughSubject<(acceleration: Vector3D, timestamp: UKTimestamp), Never>()
    public let gravitySubject = PassthroughSubject<(gravity: Vector3D, timestamp: UKTimestamp), Never>()
    public let linearAccelerationSubject = PassthroughSubject<(linearAcceleration: Vector3D, timestamp: UKTimestamp), Never>()
    public let rotationRateSubject = PassthroughSubject<(rotationRate: Rotation3D, timestamp: UKTimestamp), Never>()
    public let magnetometerSubject = PassthroughSubject<(magnetometer: Vector3D, timestamp: UKTimestamp), Never>()
    public let quaternionSubject = PassthroughSubject<(quaternion: Quaternion, timestamp: UKTimestamp), Never>()
    public let rotationSubject = PassthroughSubject<(rotation: Rotation3D, timestamp: UKTimestamp), Never>()

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout Data.Index, until finalOffset: Data.Index, timestamp: UKTimestamp) {
        while offset < finalOffset {
            let rawMotionDataType: UKMotionDataType.RawValue = data.parse(at: &offset)
            guard let motionDataType: UKMotionDataType = .init(rawValue: rawMotionDataType) else {
                logger.error("undefined motion data type \(rawMotionDataType)")
                break
            }

            let scalar = scalars[motionDataType]!

            switch motionDataType {
            case .acceleration:
                acceleration = parseVector(data: data, at: &offset, scalar: scalar)
                accelerationSubject.send((acceleration, timestamp))
            case .gravity:
                gravity = parseVector(data: data, at: &offset, scalar: scalar)
                gravitySubject.send((gravity, timestamp))
            case .linearAcceleration:
                linearAcceleration = parseVector(data: data, at: &offset, scalar: scalar)
                linearAccelerationSubject.send((linearAcceleration, timestamp))
            case .rotationRate:
                rotationRate = parseRotation(data: data, at: &offset, scalar: scalar)
                rotationRateSubject.send((rotationRate, timestamp))
            case .magnetometer:
                magnetometer = parseVector(data: data, at: &offset, scalar: scalar)
                magnetometerSubject.send((magnetometer, timestamp))
            case .quaternion:
                quaternion = parseQuaternion(data: data, at: &offset, scalar: scalar)
                quaternionSubject.send((quaternion, timestamp))
                rotation = Rotation3D(quaternion)
                rotationSubject.send((rotation, timestamp))
            }

            timestamps[motionDataType] = timestamp
        }
    }

    // MARK: - Vector

    private typealias RawVector = simd_double3
    private func parseVector(data: Data, at offset: inout Data.Index, scalar: Double) -> Vector3D {
        let rawX: Int16 = .parse(from: data, at: &offset)
        let rawY: Int16 = .parse(from: data, at: &offset)
        let rawZ: Int16 = .parse(from: data, at: &offset)

        let x = Double(rawX)
        let y = Double(rawY)
        let z = Double(rawZ)

        var rawVector: RawVector = switch deviceType {
        case .motionModule, nil:
            RawVector(arrayLiteral: -x, -z, -y)
        case .leftInsole:
            RawVector(arrayLiteral: -z, x, -y)
        case .rightInsole:
            RawVector(arrayLiteral: z, x, y)
        }
        rawVector *= scalar

        logger.debug("parsed vector: \(rawVector.debugDescription)")

        return .init(vector: rawVector)
    }

    // MARK: - Rotation

    private typealias RawAngles = simd_double3
    private func parseRotation(data: Data, at offset: inout Data.Index, scalar: Double) -> Rotation3D {
        let rawX: Int16 = .parse(from: data, at: &offset)
        let rawY: Int16 = .parse(from: data, at: &offset)
        let rawZ: Int16 = .parse(from: data, at: &offset)

        let x = Double(rawX).degreesToRadians
        let y = Double(rawY).degreesToRadians
        let z = Double(rawZ).degreesToRadians

        var rawAngles: RawAngles = switch deviceType {
        case .motionModule, nil:
            RawAngles(arrayLiteral: -x, -z, y)
        case .leftInsole:
            RawAngles(arrayLiteral: -z, y, -x)
        case .rightInsole:
            RawAngles(arrayLiteral: z, y, x)
        }
        rawAngles *= scalar

        logger.debug("parsed rotation: \(rawAngles.debugDescription)")

        let eulerAngles: EulerAngles = .init(angles: rawAngles, order: .xyz)
        return .init(eulerAngles: eulerAngles)
    }

    // MARK: - Quaternion

    private func parseQuaternion(data: Data, at offset: inout Data.Index, scalar: Double) -> Quaternion {
        let rawW: Int16 = .parse(from: data, at: &offset)
        let rawX: Int16 = .parse(from: data, at: &offset)
        let rawY: Int16 = .parse(from: data, at: &offset)
        let rawZ: Int16 = .parse(from: data, at: &offset)

        let w = Double(rawW)
        let x = Double(rawX)
        let y = Double(rawY)
        let z = Double(rawZ)

        var quaternion: Quaternion = .init(ix: x, iy: -z, iz: -y, r: -w)
        quaternion *= scalar
        quaternion = quaternion.normalized

        if deviceType?.isInsole == true {
            quaternion *= correctionQuaternion
        }

        logger.debug("parsed quaternion: \(quaternion.debugDescription)")

        return quaternion
    }

    private var correctionQuaternion: Quaternion { Self.correctionQuaternions[deviceType ?? .motionModule]! }
    static let correctionQuaternions: [UKDeviceType: Quaternion] = {
        var _correctionQuaternions: [UKDeviceType: Quaternion] = [:]

        var rawAngles: RawAngles = .init(arrayLiteral: 0.0, 0.0, 0.0)
        var eulerAngles = Rotation3D(eulerAngles: .init(angles: rawAngles, order: .xyz))
        _correctionQuaternions[.motionModule] = eulerAngles.quaternion

        rawAngles = .init(arrayLiteral: -(.pi / 2.0), .pi / 2.0, 0.0)
        eulerAngles = Rotation3D(eulerAngles: .init(angles: rawAngles, order: .xyz))
        _correctionQuaternions[.leftInsole] = eulerAngles.quaternion

        rawAngles = .init(arrayLiteral: -(.pi / 2.0), -(.pi / 2.0), 0.0)
        eulerAngles = Rotation3D(eulerAngles: .init(angles: rawAngles, order: .xyz))
        _correctionQuaternions[.rightInsole] = eulerAngles.quaternion

        return _correctionQuaternions
    }()
}
