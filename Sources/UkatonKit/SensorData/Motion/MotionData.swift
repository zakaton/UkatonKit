import CoreMotion
import Foundation
import OSLog
import simd
import Spatial
import StaticLogger

@StaticLogger
public struct MotionData: SensorDataComponent {
    // MARK: - Device Type

    var deviceType: DeviceType? = nil {
        didSet {
            if oldValue != deviceType {
                // TODO: - FILL
            }
        }
    }

    // MARK: - Data Scalar

    typealias Scalars = [MotionDataType: Double]
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

    public private(set) var acceleration: Vector3D?
    public private(set) var gravity: Vector3D?
    public private(set) var linearAcceleration: Vector3D?
    public private(set) var rotationRate: Rotation3D?
    public private(set) var magnetometer: Vector3D?
    public private(set) var quaternion: Quaternion?
    public private(set) var rotation3D: Rotation3D?

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout UInt8, until finalOffset: UInt8) {
        // TODO: - FILL
        while offset < finalOffset {
            let rawMotionDataType = data[Data.Index(offset)]
            offset += 1
            guard let motionDataType: MotionDataType = .init(rawValue: rawMotionDataType) else {
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
                rotation3D = Rotation3D(quaternion!)
            }
        }
    }

    private func parseVector(data: Data, at offset: inout UInt8, scalar: Double) -> Vector3D {
        // TODO: - FILL
        let rawX: Int16 = data.object(at: &offset)
        let rawY: Int16 = data.object(at: &offset)
        let rawZ: Int16 = data.object(at: &offset)

        let x = Double(rawX)
        let y = Double(rawY)
        let z = Double(rawZ)

        var vector: Vector3D = switch deviceType {
        case .motionModule:
            Vector3D(x: x, y: y, z: z)
        case .leftInsole:
            Vector3D(x: x, y: y, z: z)
        case .rightInsole:
            Vector3D(x: x, y: y, z: z)
        case nil:
            Vector3D(x: x, y: y, z: z)
        }

        vector.uniformlyScale(by: scalar)

        logger.debug("parsed vector: \(vector.description)")

        return vector
    }

    private func parseRotation(data: Data, at offset: inout UInt8, scalar: Double) -> Rotation3D {
        // TODO: - FILL
        let rawX: Int16 = data.object(at: &offset)
        let rawY: Int16 = data.object(at: &offset)
        let rawZ: Int16 = data.object(at: &offset)

        let x = Double(rawX)
        let y = Double(rawY)
        let z = Double(rawZ)

        return .init()
    }

    private func parseQuaternion(data: Data, at offset: inout UInt8, scalar: Double) -> Quaternion {
        // TODO: - FILL
        return .init()
    }
}
