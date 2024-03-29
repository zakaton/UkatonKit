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

public typealias UKQuaternion = simd_quatd
private let quaternionNumberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.minimumIntegerDigits = 1
    nf.minimumFractionDigits = 3
    nf.maximumFractionDigits = 3
    nf.positivePrefix = " "
    nf.paddingCharacter = "0"
    nf.paddingPosition = .afterSuffix
    return nf
}()

public extension UKQuaternion {
    fileprivate var nf: NumberFormatter { quaternionNumberFormatter }
    var strings: [String] {
        [
            "w:\(nf.string(for: vector.w)!)",
            "x:\(nf.string(for: vector.x)!)",
            "y:\(nf.string(for: vector.y)!)",
            "z:\(nf.string(for: vector.z)!)",
        ]
    }

    var string: String {
        strings.joined(separator: isWatch ? "\n" : ", ")
    }

    var array: [Double] {
        [vector.x, vector.y, vector.z, vector.w]
    }
}

private let rotation3DNumberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.minimumIntegerDigits = 1
    nf.minimumFractionDigits = 4
    nf.maximumFractionDigits = 4
    nf.positivePrefix = " "
    nf.paddingCharacter = "0"
    nf.paddingPosition = .afterSuffix
    return nf
}()

public extension Rotation3D {
    fileprivate var nf: NumberFormatter { rotation3DNumberFormatter }
    var strings: [String] {
        let angles = eulerAngles(order: .zxy).angles
        return [
            "y:\(nf.string(for: angles.x)!)",
            "p:\(nf.string(for: angles.y)!)",
            "r:\(nf.string(for: angles.z)!)",
        ]
    }

    var string: String {
        strings.joined(separator: isWatch ? "\n" : ", ")
    }

    var array: [Double] {
        let angles = eulerAngles(order: .zxy).angles
        return [angles.x, angles.y, angles.z]
    }
}

private let vector3DNumberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.minimumIntegerDigits = 2
    nf.minimumFractionDigits = 3
    nf.maximumFractionDigits = 3
    nf.positivePrefix = " "
    nf.paddingCharacter = "0"
    nf.paddingPosition = .afterSuffix
    return nf
}()

public extension Vector3D {
    fileprivate var nf: NumberFormatter { vector3DNumberFormatter }
    var strings: [String] {
        [
            "x:\(nf.string(for: x)!)",
            "y:\(nf.string(for: y)!)",
            "z:\(nf.string(for: z)!)",
        ]
    }

    var string: String {
        strings.joined(separator: isWatch ? "\n" : ", ")
    }

    var array: [Double] {
        [x, y, z]
    }
}

public typealias UKAccelerationData = (value: Vector3D, timestamp: UKTimestamp)
public typealias UKGravityData = (value: Vector3D, timestamp: UKTimestamp)
public typealias UKLinearAccelerationData = (value: Vector3D, timestamp: UKTimestamp)
public typealias UKRotationRateData = (value: Rotation3D, timestamp: UKTimestamp)
public typealias UKMagnetometerData = (value: Vector3D, timestamp: UKTimestamp)
public typealias UKQuaternionData = (value: UKQuaternion, timestamp: UKTimestamp)
public typealias UKRotationData = (value: Rotation3D, timestamp: UKTimestamp)

public typealias UKGenericMotionData = (type: UKMotionDataType, timestamp: UKTimestamp)

@StaticLogger
public class UKMotionData: UKSensorDataComponent {
    // MARK: - Device Type

    var deviceType: UKDeviceType = .motionModule

    // MARK: - Data Scalar

    typealias UKMotionScalar = Double
    typealias UKMotionScalars = [UKMotionDataType: UKMotionScalar]
    static let scalars: UKMotionScalars = [
        .acceleration: pow(2.0, -8.0),
        .gravity: pow(2.0, -8.0),
        .linearAcceleration: pow(2.0, -8.0),
        .rotationRate: pow(2.0, -9.0),
        .magnetometer: pow(2.0, -4.0),
        .quaternion: pow(2.0, -14.0),
    ]
    var scalars: UKMotionScalars { Self.scalars }

    // MARK: - Data

    public var acceleration: Vector3D { accelerationSubject.value.value }
    public var gravity: Vector3D { gravitySubject.value.value }
    public var linearAcceleration: Vector3D { linearAccelerationSubject.value.value }
    public var rotationRate: Rotation3D { rotationRateSubject.value.value }
    public var magnetometer: Vector3D { magnetometerSubject.value.value }
    public var quaternion: UKQuaternion { quaternionSubject.value.value }
    public var rotation: Rotation3D { rotationSubject.value.value }

    // MARK: - CurrentValueSubjects

    public let dataSubject = PassthroughSubject<UKGenericMotionData, Never>()

    public let accelerationSubject = CurrentValueSubject<UKAccelerationData, Never>((.init(), 0))
    public let gravitySubject = CurrentValueSubject<UKGravityData, Never>((.init(), 0))
    public let linearAccelerationSubject = CurrentValueSubject<UKLinearAccelerationData, Never>((.init(), 0))
    public let rotationRateSubject = CurrentValueSubject<UKRotationRateData, Never>((.init(), 0))
    public let magnetometerSubject = CurrentValueSubject<UKMagnetometerData, Never>((.init(), 0))
    public let quaternionSubject = CurrentValueSubject<UKQuaternionData, Never>((.init(), 0))
    public let rotationSubject = CurrentValueSubject<UKRotationData, Never>((.init(), 0))

    // MARK: - Parsing

    func parse(_ data: Data, at offset: inout Data.Index, until finalOffset: Data.Index, timestamp: UKTimestamp) {
        while offset < finalOffset {
            let rawMotionDataType: UKMotionDataType.RawValue = data.parse(at: &offset)
            guard let motionDataType: UKMotionDataType = .init(rawValue: rawMotionDataType) else {
                logger.error("undefined motion data type \(rawMotionDataType)")
                break
            }

            let scalar = scalars[motionDataType]!

            switch motionDataType {
            case .acceleration:
                let newAcceleration = parseVector(data: data, at: &offset, scalar: scalar)
                accelerationSubject.send((newAcceleration, timestamp))
            case .gravity:
                let newGravity = parseVector(data: data, at: &offset, scalar: scalar)
                gravitySubject.send((newGravity, timestamp))
            case .linearAcceleration:
                let newLinearAcceleration = parseVector(data: data, at: &offset, scalar: scalar)
                linearAccelerationSubject.send((newLinearAcceleration, timestamp))
            case .rotationRate:
                let newRotationRate = parseRotation(data: data, at: &offset, scalar: scalar)
                rotationRateSubject.send((newRotationRate, timestamp))
            case .magnetometer:
                let newMagnetometer = parseVector(data: data, at: &offset, scalar: scalar)
                magnetometerSubject.send((newMagnetometer, timestamp))
            case .quaternion:
                let newQuaternion = parseQuaternion(data: data, at: &offset, scalar: scalar)
                quaternionSubject.send((newQuaternion, timestamp))

                let newRotation = Rotation3D(newQuaternion)
                rotationSubject.send((newRotation, timestamp))
            }

            dataSubject.send((motionDataType, timestamp))
        }
    }

    // MARK: - Vector

    private typealias UKRawMotionVector3D = simd_double3
    private func parseVector(data: Data, at offset: inout Data.Index, scalar: Double) -> Vector3D {
        let rawX: Int16 = .parse(from: data, at: &offset)
        let rawY: Int16 = .parse(from: data, at: &offset)
        let rawZ: Int16 = .parse(from: data, at: &offset)

        let x = Double(rawX)
        let y = Double(rawY)
        let z = Double(rawZ)

        var rawVector: UKRawMotionVector3D = switch deviceType {
        case .motionModule:
            UKRawMotionVector3D(arrayLiteral: x, -z, -y)
        case .leftInsole:
            UKRawMotionVector3D(arrayLiteral: z, y, x)
        case .rightInsole:
            UKRawMotionVector3D(arrayLiteral: -z, y, -x)
        }
        rawVector *= scalar

        logger.debug("parsed vector: \(rawVector.debugDescription)")

        return .init(vector: rawVector)
    }

    // MARK: - Rotation

    private typealias UKRawEulerAngles = simd_double3
    private func parseRotation(data: Data, at offset: inout Data.Index, scalar: Double) -> Rotation3D {
        let rawX: Int16 = .parse(from: data, at: &offset)
        let rawY: Int16 = .parse(from: data, at: &offset)
        let rawZ: Int16 = .parse(from: data, at: &offset)

        let x = Double(rawX).degreesToRadians
        let y = Double(rawY).degreesToRadians
        let z = Double(rawZ).degreesToRadians

        var rawAngles: UKRawEulerAngles = switch deviceType {
        case .motionModule:
            UKRawEulerAngles(arrayLiteral: -x, z, y)
        case .leftInsole:
            UKRawEulerAngles(arrayLiteral: -z, -y, -x)
        case .rightInsole:
            UKRawEulerAngles(arrayLiteral: z, -y, x)
        }
        rawAngles *= scalar

        logger.debug("parsed rotation: \(rawAngles.debugDescription)")

        let eulerAngles: EulerAngles = .init(angles: rawAngles, order: .xyz)
        return .init(eulerAngles: eulerAngles)
    }

    // MARK: - Quaternion

    private func parseQuaternion(data: Data, at offset: inout Data.Index, scalar: Double) -> UKQuaternion {
        let rawW: Int16 = .parse(from: data, at: &offset)
        let rawX: Int16 = .parse(from: data, at: &offset)
        let rawY: Int16 = .parse(from: data, at: &offset)
        let rawZ: Int16 = .parse(from: data, at: &offset)

        let w = Double(rawW)
        let x = Double(rawX)
        let y = Double(rawY)
        let z = Double(rawZ)

        var quaternion: UKQuaternion = .init(ix: x, iy: -z, iz: -y, r: -w)
        quaternion *= scalar
        quaternion = quaternion.normalized

        if deviceType.isInsole {
            quaternion *= correctionQuaternion
        }

        logger.debug("parsed quaternion: \(quaternion.debugDescription)")

        return quaternion
    }

    private var correctionQuaternion: UKQuaternion { Self.correctionQuaternions[deviceType]! }
    static let correctionQuaternions: [UKDeviceType: UKQuaternion] = {
        var _correctionQuaternions: [UKDeviceType: UKQuaternion] = [:]

        var rawAngles: UKRawEulerAngles = .init(arrayLiteral: 0.0, 0.0, 0.0)
        var eulerAngles = Rotation3D(eulerAngles: .init(angles: rawAngles, order: .xyz))
        _correctionQuaternions[.motionModule] = eulerAngles.quaternion

        rawAngles = .init(arrayLiteral: -(.pi / 2.0), 0.0, -(.pi / 2.0))
        eulerAngles = Rotation3D(eulerAngles: .init(angles: rawAngles, order: .xyz))
        _correctionQuaternions[.leftInsole] = eulerAngles.quaternion

        rawAngles = .init(arrayLiteral: -(.pi / 2.0), 0.0, .pi / 2.0)
        eulerAngles = Rotation3D(eulerAngles: .init(angles: rawAngles, order: .xyz))
        _correctionQuaternions[.rightInsole] = eulerAngles.quaternion

        return _correctionQuaternions
    }()

    // MARK: - JSON

    public func json(for motionDataType: UKMotionDataType) -> Any {
        switch motionDataType {
        case .acceleration:
            acceleration.array
        case .gravity:
            gravity.array
        case .linearAcceleration:
            linearAcceleration.array
        case .rotationRate:
            rotationRate.array
        case .magnetometer:
            magnetometer.array
        case .quaternion:
            quaternion.array
        }
    }
}
