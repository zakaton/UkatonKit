import Combine
import Foundation
import OSLog
import simd
import UkatonMacros

public typealias UKPressureCenterOfMass = simd_double2
public typealias UKPressureMass = Double
public typealias UKPressureHeelToToe = Float64

typealias UKPressureRawMass = UInt32

typealias UKPressureScalar = Double
typealias UKPressureScalars = [UKPressureDataType: UKPressureScalar]

public extension UKPressureCenterOfMass {
    var string: String {
        .init(format: "x: %5.3f, y: %5.3f", x, y)
    }
}

@StaticLogger
public struct UKPressureData: UKSensorDataComponent {
    // MARK: - Device Type

    var deviceType: UKDeviceType? = nil {
        didSet {
            if oldValue != deviceType {
                pressureValuesSubject.value.pressureValues.deviceType = deviceType
            }
        }
    }

    // MARK: - Data Scalar

    static let scalars: UKPressureScalars = [
        .mass: pow(2.0, -16.0)
    ]
    var scalars: UKPressureScalars { Self.scalars }

    // MARK: - Data

    public var pressureValues: UKPressureValues { pressureValuesSubject.value.pressureValues }
    public var centerOfMass: UKPressureCenterOfMass { centerOfMassSubject.value.centerOfMass }
    public var mass: UKPressureMass { massSubject.value.mass }
    public var heelToToe: UKPressureHeelToToe { heelToToeSubject.value.heelToToe }

    public private(set) var timestamps: [UKPressureDataType: UKTimestamp] = .zero

    // MARK: - CurrentValueSubjects

    public let pressureValuesSubject = CurrentValueSubject<(pressureValues: UKPressureValues, timestamp: UKTimestamp), Never>((.init(), 0))
    public let centerOfMassSubject = CurrentValueSubject<(centerOfMass: UKPressureCenterOfMass, timestamp: UKTimestamp), Never>((.init(), 0))
    public let massSubject = CurrentValueSubject<(mass: UKPressureMass, timestamp: UKTimestamp), Never>((.zero, 0))
    public let heelToToeSubject = CurrentValueSubject<(heelToToe: UKPressureHeelToToe, timestamp: UKTimestamp), Never>((.zero, 0))

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout Data.Index, until finalOffset: Data.Index, timestamp: UKTimestamp) {
        while offset < finalOffset {
            let rawPressureDataType: UKPressureDataType.RawValue = data.parse(at: &offset)
            guard let pressureDataType: UKPressureDataType = .init(rawValue: rawPressureDataType) else {
                logger.error("undefined pressure data type \(rawPressureDataType)")
                break
            }

            switch pressureDataType {
            case .pressureSingleByte, .pressureDoubleByte:
                pressureValuesSubject.value.pressureValues.parse(data, at: &offset, for: pressureDataType)
                pressureValuesSubject.send((pressureValues, timestamp))

                centerOfMassSubject.send((pressureValues.centerOfMass, timestamp))

                massSubject.send((pressureValues.mass, timestamp))

                heelToToeSubject.send((pressureValues.heelToToe, timestamp))

            case .centerOfMass:
                let newCenterOfMass = parseCenterOfMass(data: data, at: &offset)
                centerOfMassSubject.send((newCenterOfMass, timestamp))
                logger.debug("\(pressureDataType.name): \(newCenterOfMass.debugDescription)")
            case .mass:
                let newMass = Double(parseMass(data: data, at: &offset)) * scalars[pressureDataType]!
                massSubject.send((newMass, timestamp))
                logger.debug("\(pressureDataType.name): \(newMass.debugDescription)")
            case .heelToToe:
                let newHeelToToe = parseHeelToToe(data: data, at: &offset)
                heelToToeSubject.send((newHeelToToe, timestamp))
                logger.debug("\(pressureDataType.name): \(newHeelToToe.debugDescription)")
            }
        }
    }

    private mutating func parseCenterOfMass(data: Data, at offset: inout Data.Index) -> UKPressureCenterOfMass {
        .init(
            x: Double(Float32.parse(from: data, at: &offset)),
            y: Double(Float32.parse(from: data, at: &offset))
        )
    }

    private mutating func parseMass(data: Data, at offset: inout Data.Index) -> UKPressureRawMass {
        .parse(from: data, at: &offset)
    }

    private mutating func parseHeelToToe(data: Data, at offset: inout Data.Index) -> UKPressureHeelToToe {
        .parse(from: data, at: &offset)
    }
}
