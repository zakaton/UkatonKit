import Combine
import Foundation
import OSLog
import simd
import UkatonMacros

public typealias UKCenterOfMass = simd_double2
public typealias UKMass = Double
public typealias UKHeelToToe = Float64

typealias UKPressureRawMass = UInt32

typealias UKPressureScalar = Double
typealias UKPressureScalars = [UKPressureDataType: UKPressureScalar]

public extension UKCenterOfMass {
    var string: String {
        .init(format: "x: %5.3f, y: %5.3f", x, y)
    }
}

public typealias UKPressureValuesData = (value: UKPressureValues, timestamp: UKTimestamp)
public typealias UKCenterOfMassData = (value: UKCenterOfMass, timestamp: UKTimestamp)
public typealias UKMassData = (value: UKMass, timestamp: UKTimestamp)
public typealias UKHeelToToeData = (value: UKHeelToToe, timestamp: UKTimestamp)

@StaticLogger
public struct UKPressureData: UKSensorDataComponent {
    // MARK: - Device Type

    var deviceType: UKDeviceType = .motionModule

    // MARK: - Data Scalar

    static let scalars: UKPressureScalars = [
        .mass: pow(2.0, -16.0)
    ]
    var scalars: UKPressureScalars { Self.scalars }

    // MARK: - Data

    public var pressureValues: UKPressureValues { pressureValuesSubject.value.value }
    public var centerOfMass: UKCenterOfMass { centerOfMassSubject.value.value }
    public var mass: UKMass { massSubject.value.value }
    public var heelToToe: UKHeelToToe { heelToToeSubject.value.value }

    // MARK: - CurrentValueSubjects

    public let pressureValuesSubject = CurrentValueSubject<UKPressureValuesData, Never>((.init(), 0))
    public let centerOfMassSubject = CurrentValueSubject<UKCenterOfMassData, Never>((.init(), 0))
    public let massSubject = CurrentValueSubject<UKMassData, Never>((.zero, 0))
    public let heelToToeSubject = CurrentValueSubject<UKHeelToToeData, Never>((.zero, 0))

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
                let newPressureValues: UKPressureValues = .init(data: data, at: &offset, for: pressureDataType, as: deviceType)
                pressureValuesSubject.send((newPressureValues, timestamp))

                centerOfMassSubject.send((newPressureValues.centerOfMass, timestamp))

                massSubject.send((newPressureValues.mass, timestamp))

                heelToToeSubject.send((newPressureValues.heelToToe, timestamp))

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

    private mutating func parseCenterOfMass(data: Data, at offset: inout Data.Index) -> UKCenterOfMass {
        .init(
            x: .init(Float32.parse(from: data, at: &offset)),
            y: .init(Float32.parse(from: data, at: &offset))
        )
    }

    private mutating func parseMass(data: Data, at offset: inout Data.Index) -> UKPressureRawMass {
        .parse(from: data, at: &offset)
    }

    private mutating func parseHeelToToe(data: Data, at offset: inout Data.Index) -> UKHeelToToe {
        .parse(from: data, at: &offset)
    }
}
