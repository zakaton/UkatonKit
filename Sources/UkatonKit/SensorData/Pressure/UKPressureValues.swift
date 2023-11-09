import Foundation
import OSLog
import simd
import UkatonMacros

@StaticLogger
public struct UKPressureValues {
    static let pressurePositions: [UKPressureValue.Vector2D] = [
        .init(x: 0.6385579634772724, y: 0.12185506415310729),
        .init(x: 0.3549331417480725, y: 0.15901519981589698),
        .init(x: 0.7452523671145329, y: 0.20937944459744443),
        .init(x: 0.4729939843657848, y: 0.24446464882728644),
        .init(x: 0.21767802953129523, y: 0.27125012732533793),
        .init(x: 0.6841309499554993, y: 0.305958071294644),
        .init(x: 0.4443634258018164, y: 0.34255231656662977),
        .init(x: 0.2058826683251659, y: 0.3878235478309421),
        .init(x: 0.5179235875054955, y: 0.4515805318615153),
        .init(x: 0.19087039042645593, y: 0.49232463999939635),
        .init(x: 0.4643083092958169, y: 0.6703914829723581),
        .init(x: 0.19301500155484305, y: 0.6677506611486066),
        .init(x: 0.4643083092958169, y: 0.7567840826350875),
        .init(x: 0.19301500155484305, y: 0.7545205210718718),
        .init(x: 0.46645292042420405, y: 0.9129698304969649),
        .init(x: 0.19891268215790772, y: 0.9133470907575008)
    ]

    // MARK: - DeviceType

    var deviceType: UKDeviceType? = nil {
        didSet {
            if let deviceType, deviceType != oldValue {
                if deviceType.isInsole == true {
                    for index in 0 ..< numberOfPressureSensors {
                        rawValues[index].position = Self.pressurePositions[index]
                        if deviceType.insoleSide == .right {
                            rawValues[index].position.x = 1 - rawValues[index].position.x
                        }
                    }
                    logger.debug("updated pressure value positions")
                }
            }
        }
    }

    // MARK: - Data Scalar

    typealias Scalars = [UKPressureDataType: Double]
    static let scalars: Scalars = [
        .pressureSingleByte: pow(2.0, -8.0),
        .pressureDoubleByte: pow(2.0, -12.0)
    ]
    var scalars: Scalars { Self.scalars }

    // MARK: - Raw Values

    static let numberOfPressureSensors: Int = 16
    public var numberOfPressureSensors: Int { Self.numberOfPressureSensors }
    public private(set) var rawValues: [UKPressureValue] = .init(repeating: .init(), count: numberOfPressureSensors)
    public var string: String {
        rawValues.map { String($0.rawValue) }.joined(separator: ",")
    }

    public subscript(index: Data.Index) -> UKPressureValue {
        rawValues[index]
    }

    // MARK: - Derived Values

    public typealias Vector2D = simd_double2

    public private(set) var centerOfMass: Vector2D = .zero
    public private(set) var mass: Double = .zero
    public private(set) var heelToToe: Float64 = .zero

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout Data.Index, for pressureDataType: UKPressureDataType) {
        let scalar = scalars[pressureDataType]!

        var rawValueSum = 0
        let isSingleByte = pressureDataType == .pressureSingleByte

        for index in 0 ..< numberOfPressureSensors {
            if isSingleByte {
                rawValues[index].rawValue = UInt16(UInt8.parse(from: data, at: &offset))
            }
            else {
                rawValues[index].rawValue = UInt16.parse(from: data, at: &offset)
            }

            rawValueSum += Int(rawValues[index].rawValue)
            rawValues[index].normalizedValue = Double(rawValues[index].rawValue) * scalar
        }

        logger.debug("rawValueSum: \(rawValueSum)")

        centerOfMass = .zero
        heelToToe = .zero

        if rawValueSum > 0 {
            for index in 0 ..< numberOfPressureSensors {
                rawValues[index].weightedValue = Double(rawValues[index].rawValue) / Double(rawValueSum)
                centerOfMass += rawValues[index].position * rawValues[index].weightedValue
            }

            centerOfMass.y = 1.0 - centerOfMass.y
            heelToToe = centerOfMass.y
        }

        mass = Double(rawValueSum) * scalar / Double(numberOfPressureSensors)

        let _self = self
        logger.debug("pressure sensors: \(_self.rawValues.map { $0.rawValue })")
        logger.debug("centerOfMass: \(_self.centerOfMass.debugDescription)")
        logger.debug("heelToToe: \(_self.heelToToe.debugDescription)")
        logger.debug("mass: \(_self.mass)")
    }
}
