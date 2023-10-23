import CoreMotion
import Foundation
import OSLog
import simd
import Spatial
import StaticLogger

extension BinaryFloatingPoint {
    var degreesToRadians: Self {
        self * .pi / 180
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

    public typealias Quaternion = simd_quatd

    public private(set) var acceleration: Vector3D = .init()
    public private(set) var gravity: Vector3D = .init()
    public private(set) var linearAcceleration: Vector3D = .init()
    public private(set) var rotationRate: Rotation3D = .init()
    public private(set) var magnetometer: Vector3D = .init()
    public private(set) var quaternion: Quaternion = .init()
    public private(set) var rotation: Rotation3D = .init()

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout UInt8, until finalOffset: UInt8) {
        while offset < finalOffset {
            let rawMotionDataType = data[Data.Index(offset)]
            offset += 1
            guard let motionDataType: UKMotionDataType = .init(rawValue: rawMotionDataType) else {
                logger.error("undefined motion data type \(rawMotionDataType)")
                break
            }

            let scalar = scalars[motionDataType]!

            switch motionDataType {
            case .acceleration:
                acceleration = parseVector(data: data, at: &offset, scalar: scalar)
            case .gravity:
                gravity = parseVector(data: data, at: &offset, scalar: scalar)
            case .linearAcceleration:
                linearAcceleration = parseVector(data: data, at: &offset, scalar: scalar)
            case .rotationRate:
                rotationRate = parseRotation(data: data, at: &offset, scalar: scalar)
            case .magnetometer:
                magnetometer = parseVector(data: data, at: &offset, scalar: scalar)
            case .quaternion:
                quaternion = parseQuaternion(data: data, at: &offset, scalar: scalar)
                rotation = Rotation3D(quaternion)
            }
        }
    }

    private typealias RawVector = simd_double3
    private func parseVector(data: Data, at offset: inout UInt8, scalar: Double) -> Vector3D {
        let rawX: Int16 = data.object(at: &offset)
        let rawY: Int16 = data.object(at: &offset)
        let rawZ: Int16 = data.object(at: &offset)

        let x = Double(rawX)
        let y = Double(rawY)
        let z = Double(rawZ)

        var rawVector: RawVector = switch deviceType {
        case .motionModule:
            RawVector(arrayLiteral: -y, -z, -x)
        case .leftInsole:
            RawVector(arrayLiteral: -z, x, -y)
        case .rightInsole:
            RawVector(arrayLiteral: z, x, y)
        case nil:
            RawVector(arrayLiteral: x, y, z)
        }
        rawVector *= scalar

        logger.debug("parsed vector: \(rawVector.debugDescription)")

        return .init(vector: rawVector)
    }

    private typealias RawAngles = simd_double3
    private func parseRotation(data: Data, at offset: inout UInt8, scalar: Double) -> Rotation3D {
        let rawX: Int16 = data.object(at: &offset)
        let rawY: Int16 = data.object(at: &offset)
        let rawZ: Int16 = data.object(at: &offset)

        let x = Double(rawX).degreesToRadians
        let y = Double(rawY).degreesToRadians
        let z = Double(rawZ).degreesToRadians

        var rawAngles: RawAngles = switch deviceType {
        case .motionModule:
            RawAngles(arrayLiteral: y, -z, x)
        case .leftInsole:
            RawAngles(arrayLiteral: -z, y, -x)
        case .rightInsole:
            RawAngles(arrayLiteral: z, y, x)
        case nil:
            RawAngles(arrayLiteral: x, y, z)
        }
        rawAngles *= scalar

        let eulerAngles: EulerAngles = .init(angles: rawAngles, order: .xyz)
        return .init(eulerAngles: eulerAngles)
    }

    private func parseQuaternion(data: Data, at offset: inout UInt8, scalar: Double) -> Quaternion {
        let rawW: Int16 = data.object(at: &offset)
        let rawX: Int16 = data.object(at: &offset)
        let rawY: Int16 = data.object(at: &offset)
        let rawZ: Int16 = data.object(at: &offset)

        let w = Double(rawW)
        let x = Double(rawX)
        let y = Double(rawY)
        let z = Double(rawZ)

        var quaternion: Quaternion = .init(ix: x, iy: -z, iz: -y, r: -w)
        if deviceType?.isInsole == true {
            quaternion *= correctionQuaternion
        }

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
