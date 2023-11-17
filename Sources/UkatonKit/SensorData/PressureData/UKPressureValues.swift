import Foundation
import OSLog
import simd
import UkatonMacros

typealias UKRawPressureValueSum = UInt32

@StaticLogger
public struct UKPressureValues: RandomAccessCollection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { numberOfPressureSensors }

    public init() {}

    static let pressurePositions: [UKPressurePosition] = [
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

    // MARK: - Data Scalar

    static let scalars: UKPressureScalars = [
        .pressureSingleByte: pow(2.0, -8.0),
        .pressureDoubleByte: pow(2.0, -12.0)
    ]
    var scalars: UKPressureScalars { Self.scalars }

    // MARK: - Raw Values

    static let numberOfPressureSensors: Int = 16
    public var numberOfPressureSensors: Int { Self.numberOfPressureSensors }
    public private(set) var rawValues: [UKPressureValue] = .init(repeating: .init(), count: numberOfPressureSensors)
    public var string: String {
        rawValues.map { String(format: "%\(isSingleByte ? "3" : "4")d", $0.rawValue) }.joined(separator: ", ")
    }

    public subscript(index: Data.Index) -> UKPressureValue {
        rawValues[index]
    }

    // MARK: - Derived Values

    public private(set) var centerOfMass: UKCenterOfMass = .zero
    public private(set) var mass: UKMass = .zero
    public private(set) var heelToToe: UKHeelToToe = .zero

    // MARK: - Parsing

    public private(set) var latestPressureDataType: UKPressureDataType = .pressureSingleByte
    public private(set) var isSingleByte: Bool = true
    private(set) var rawValueSum: UKRawPressureValueSum = 0
    init(data: Data, at offset: inout Data.Index, for pressureDataType: UKPressureDataType, as deviceType: UKDeviceType) {
        latestPressureDataType = pressureDataType

        for index in 0 ..< numberOfPressureSensors {
            rawValues[index].position = Self.pressurePositions[index]
            if deviceType.insoleSide == .right {
                rawValues[index].position.x = 1 - rawValues[index].position.x
            }
        }

        let scalar = scalars[pressureDataType]!
        isSingleByte = pressureDataType == .pressureSingleByte

        rawValueSum = 0
        for index in 0 ..< numberOfPressureSensors {
            if isSingleByte {
                rawValues[index].rawValue = UKRawPressureValue(UInt8.parse(from: data, at: &offset))
            }
            else {
                rawValues[index].rawValue = UKRawPressureValue(UInt16.parse(from: data, at: &offset))
            }

            rawValueSum += UKRawPressureValueSum(rawValues[index].rawValue)
            rawValues[index].normalizedValue = UKNormalizedPressureValue(rawValues[index].rawValue) * scalar
        }

        centerOfMass = .zero
        heelToToe = .zero

        if rawValueSum > 0 {
            for index in 0 ..< numberOfPressureSensors {
                rawValues[index].weightedValue = UKWeightedPressureValue(rawValues[index].rawValue) / UKWeightedPressureValue(rawValueSum)
                centerOfMass += rawValues[index].position * rawValues[index].weightedValue
            }

            centerOfMass.y = 1.0 - centerOfMass.y
            heelToToe = centerOfMass.y
        }

        mass = Double(rawValueSum) * scalar / Double(numberOfPressureSensors)

        let _self = self
        logger.debug("rawValueSum: \(_self.rawValueSum)")
        logger.debug("pressure sensors: \(_self.rawValues.map { $0.rawValue })")
        logger.debug("centerOfMass: \(_self.centerOfMass.debugDescription)")
        logger.debug("heelToToe: \(_self.heelToToe.debugDescription)")
        logger.debug("mass: \(_self.mass)")
    }
}
