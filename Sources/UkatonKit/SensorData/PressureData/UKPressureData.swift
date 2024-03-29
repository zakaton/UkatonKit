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

    var array: [Double] {
        [x, y]
    }
}

public typealias UKPressureValuesData = (value: UKPressureValues, timestamp: UKTimestamp)
public typealias UKCenterOfMassData = (value: UKCenterOfMass, timestamp: UKTimestamp)
public typealias UKMassData = (value: UKMass, timestamp: UKTimestamp)
public typealias UKHeelToToeData = (value: UKHeelToToe, timestamp: UKTimestamp)

public typealias UKGenericPressureData = (type: UKPressureDataType, timestamp: UKTimestamp)

@StaticLogger
public class UKPressureData: UKSensorDataComponent {
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

    public let dataSubject = PassthroughSubject<UKGenericPressureData, Never>()

    public let pressureValuesSubject = CurrentValueSubject<UKPressureValuesData, Never>((.init(), 0))
    public let centerOfMassSubject = CurrentValueSubject<UKCenterOfMassData, Never>((.init(), 0))
    public let massSubject = CurrentValueSubject<UKMassData, Never>((.zero, 0))
    public let heelToToeSubject = CurrentValueSubject<UKHeelToToeData, Never>((.zero, 0))

    // MARK: - CenterOfMass Calibration

    var lowerCenterOfMass: UKCenterOfMass = .init(x: .infinity, y: .infinity)
    var upperCenterOfMass: UKCenterOfMass = .init(x: -.infinity, y: -.infinity)
    public func recalibrateCenterOfMass() {
        lowerCenterOfMass = .init(x: .infinity, y: .infinity)
        upperCenterOfMass = .init(x: -.infinity, y: -.infinity)

        lowerMass = .infinity
        upperMass = -.infinity
    }

    func updateCenterOfMassRange(with centerOfMass: UKCenterOfMass) {
        lowerCenterOfMass.x = min(lowerCenterOfMass.x, centerOfMass.x)
        lowerCenterOfMass.y = min(lowerCenterOfMass.y, centerOfMass.y)

        upperCenterOfMass.x = max(upperCenterOfMass.x, centerOfMass.x)
        upperCenterOfMass.y = max(upperCenterOfMass.y, centerOfMass.y)
    }

    func normalizeCenterOfMass(_ centerOfMass: inout UKCenterOfMass) {
        centerOfMass.x = getInterpolation(of: centerOfMass.x, between: lowerCenterOfMass.x, and: upperCenterOfMass.x)
        centerOfMass.y = getInterpolation(of: centerOfMass.y, between: lowerCenterOfMass.y, and: upperCenterOfMass.y)
    }

    // MARK: - Mass Calibration

    var lowerMass: UKMass = .infinity
    var upperMass: UKMass = -.infinity

    func updateMassRange(with mass: UKMass) {
        lowerMass = min(lowerMass, mass)
        upperMass = max(upperMass, mass)
    }

    func normalizeMass(_ mass: inout UKMass) {
        mass = getInterpolation(of: mass, between: lowerMass, and: upperMass)
    }

    // MARK: - Parsing

    func parse(_ data: Data, at offset: inout Data.Index, until finalOffset: Data.Index, timestamp: UKTimestamp) {
        while offset < finalOffset {
            let rawPressureDataType: UKPressureDataType.RawValue = data.parse(at: &offset)
            guard let pressureDataType: UKPressureDataType = .init(rawValue: rawPressureDataType) else {
                logger.error("undefined pressure data type \(rawPressureDataType)")
                break
            }

            switch pressureDataType {
            case .pressureSingleByte, .pressureDoubleByte:
                var newPressureValues: UKPressureValues = .init(data: data, at: &offset, for: pressureDataType, as: deviceType)

                pressureValuesSubject.send((newPressureValues, timestamp))

                if newPressureValues.rawValueSum > 0 {
                    updateCenterOfMassRange(with: newPressureValues.centerOfMass)
                    updateMassRange(with: newPressureValues.mass)
                }
                normalizeCenterOfMass(&newPressureValues.centerOfMass)
                normalizeMass(&newPressureValues.mass)

                centerOfMassSubject.send((newPressureValues.centerOfMass, timestamp))
                dataSubject.send((.centerOfMass, timestamp))

                massSubject.send((newPressureValues.mass, timestamp))
                dataSubject.send((.mass, timestamp))

                heelToToeSubject.send((newPressureValues.heelToToe, timestamp))
                dataSubject.send((.heelToToe, timestamp))

            case .centerOfMass:
                var newCenterOfMass = parseCenterOfMass(data: data, at: &offset)
                updateCenterOfMassRange(with: newCenterOfMass)
                normalizeCenterOfMass(&newCenterOfMass)
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

            dataSubject.send((pressureDataType, timestamp))
        }
    }

    func parseCenterOfMass(data: Data, at offset: inout Data.Index) -> UKCenterOfMass {
        .init(
            x: .init(Float32.parse(from: data, at: &offset)),
            y: .init(Float32.parse(from: data, at: &offset))
        )
    }

    func parseMass(data: Data, at offset: inout Data.Index) -> UKPressureRawMass {
        .parse(from: data, at: &offset)
    }

    func parseHeelToToe(data: Data, at offset: inout Data.Index) -> UKHeelToToe {
        .parse(from: data, at: &offset)
    }

    // MARK: - JSON

    public func json(for pressureDataType: UKPressureDataType) -> Any {
        switch pressureDataType {
        case .pressureSingleByte, .pressureDoubleByte:
            pressureValues.json
        case .centerOfMass:
            centerOfMass.array
        case .mass:
            mass
        case .heelToToe:
            heelToToe
        }
    }
}
