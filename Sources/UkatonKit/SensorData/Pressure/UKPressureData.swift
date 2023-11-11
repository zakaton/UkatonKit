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
                pressureValues.deviceType = deviceType
            }
        }
    }

    // MARK: - Data Scalar

    static let scalars: UKPressureScalars = [
        .mass: pow(2.0, -16.0)
    ]
    var scalars: UKPressureScalars { Self.scalars }

    // MARK: - Data

    public private(set) var pressureValues: UKPressureValues = .init()
    public private(set) var centerOfMass: UKPressureCenterOfMass = .init()
    public private(set) var mass: UKPressureMass = .zero
    public private(set) var heelToToe: UKPressureHeelToToe = .zero

    public private(set) var timestamps: [UKPressureDataType: UKTimestamp] = .zero

    // MARK: - PassthroughSubjects

    public let pressureValuesSubject = PassthroughSubject<(pressureValues: UKPressureValues, timestamp: UKTimestamp), Never>()
    public let centerOfMassSubject = PassthroughSubject<(centerOfMass: UKPressureCenterOfMass, timestamp: UKTimestamp), Never>()
    public let massSubject = PassthroughSubject<(mass: UKPressureMass, timestamp: UKTimestamp), Never>()
    public let heelToToeSubject = PassthroughSubject<(heelToToe: UKPressureHeelToToe, timestamp: UKTimestamp), Never>()

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
                pressureValues.parse(data, at: &offset, for: pressureDataType)
                pressureValuesSubject.send((pressureValues, timestamp))

                centerOfMass = pressureValues.centerOfMass
                timestamps[.centerOfMass] = timestamp
                centerOfMassSubject.send((centerOfMass, timestamp))

                mass = pressureValues.mass
                timestamps[.mass] = timestamp
                massSubject.send((mass, timestamp))

                heelToToe = pressureValues.heelToToe
                timestamps[.heelToToe] = timestamp
                heelToToeSubject.send((heelToToe, timestamp))

            case .centerOfMass:
                centerOfMass = parseCenterOfMass(data: data, at: &offset)
                centerOfMassSubject.send((centerOfMass, timestamp))
                let _self = self
                logger.debug("\(pressureDataType.name): \(_self.centerOfMass.debugDescription)")
            case .mass:
                mass = Double(parseMass(data: data, at: &offset)) * scalars[pressureDataType]!
                massSubject.send((mass, timestamp))
                let _self = self
                logger.debug("\(pressureDataType.name): \(_self.mass.debugDescription)")
            case .heelToToe:
                heelToToe = parseHeelToToe(data: data, at: &offset)
                heelToToeSubject.send((heelToToe, timestamp))
                let _self = self
                logger.debug("\(pressureDataType.name): \(_self.heelToToe.debugDescription)")
            }

            timestamps[pressureDataType] = timestamp
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
