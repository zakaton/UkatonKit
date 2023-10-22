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
    public private(set) var euler: EulerAngles?

    // MARK: - Parsing

    func parse(_ data: Data, at offset: inout UInt8, until finalOffset: UInt8) {
        // TODO: - FILL
    }
}
