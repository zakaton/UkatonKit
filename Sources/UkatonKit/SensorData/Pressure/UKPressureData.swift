import Foundation
import OSLog
import simd
import StaticLogger

@StaticLogger
public struct UKPressureData: UKSensorDataComponent {
    // MARK: - Device Type

    var deviceType: UKDeviceType? = nil {
        didSet {
            if oldValue != deviceType {
                pressureValues.deviceType = deviceType
            }
        }
    }

    // MARK: - Data Scalar

    typealias Scalars = [UKPressureDataType: Double]
    static let scalars: Scalars = [
        .mass: pow(2.0, -16.0)
    ]
    var scalars: Scalars { Self.scalars }

    // MARK: - Data

    public typealias Vector2D = simd_double2

    public private(set) var pressureValues: UKPressureValues = .init()
    public private(set) var centerOfMass: Vector2D = .init()
    public private(set) var mass: Double = .zero
    public private(set) var heelToToe: Float64 = .zero

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout UInt8, until finalOffset: UInt8) {
        while offset < finalOffset {
            let rawPressureDataType = data[Data.Index(offset)]
            offset += 1
            guard let pressureDataType: UKPressureDataType = .init(rawValue: rawPressureDataType) else {
                logger.error("undefined pressure data type \(rawPressureDataType)")
                break
            }

            let _self = self

            switch pressureDataType {
            case .pressureSingleByte, .pressureDoubleByte:
                pressureValues.parse(data, at: &offset, for: pressureDataType)
                centerOfMass = pressureValues.centerOfMass
                mass = pressureValues.mass
                heelToToe = pressureValues.heelToToe
            case .centerOfMass:
                centerOfMass = parseCenterOfMass(data: data, at: &offset)
                logger.debug("\(pressureDataType.name): \(_self.centerOfMass.debugDescription)")
            case .mass:
                mass = Double(parseMass(data: data, at: &offset)) * scalars[pressureDataType]!
                logger.debug("\(pressureDataType.name): \(_self.mass.debugDescription)")
            case .heelToToe:
                heelToToe = parseHeelToToe(data: data, at: &offset)
                logger.debug("\(pressureDataType.name): \(_self.heelToToe.debugDescription)")
            }
        }
    }

    private mutating func parseCenterOfMass(data: Data, at offset: inout UInt8) -> Vector2D {
        .init(
            x: .parse(from: data, at: &offset),
            y: .parse(from: data, at: &offset)
        )
    }

    private mutating func parseMass(data: Data, at offset: inout UInt8) -> UInt32 {
        .parse(from: data, at: &offset)
    }

    private mutating func parseHeelToToe(data: Data, at offset: inout UInt8) -> Float64 {
        .parse(from: data, at: &offset)
    }
}
