import Foundation
import OSLog
import UkatonMacros

public typealias UKSensorDataRate = UInt16

public typealias UKMotionDataRates = [UKMotionDataType: UKSensorDataRate]
public typealias UKPressureDataRates = [UKPressureDataType: UKSensorDataRate]

extension Dictionary where Key: CaseIterable & RawRepresentable, Key.RawValue: Numeric, Value == UKSensorDataRate {
    static func - (lhs: Self, rhs: Self) -> Self {
        var difference = Self()

        for (key, value) in lhs {
            if rhs[key] != value {
                difference[key] = value
            }
        }

        return difference
    }

    static func min(_ lhs: Self, _ rhs: Self) -> Self {
        var minValue: Self = .zero

        for (key, _) in minValue {
            minValue[key] = Swift.min(lhs[key]!, rhs[key]!)
        }

        return minValue
    }

    var withoutZeros: Self {
        filter { $1 > 0 }
    }
}

@StaticLogger
public struct UKSensorDataConfigurations {
    public var motion: UKMotionDataRates
    public var pressure: UKPressureDataRates {
        didSet {
            if let singleByte = pressure[.pressureSingleByte], let doubleByte = pressure[.pressureDoubleByte], singleByte > 0, doubleByte > 0 {
                if let oldSingleByte = oldValue[.pressureSingleByte], oldSingleByte > 0 {
                    pressure[.pressureSingleByte] = 0
                }
                else {
                    pressure[.pressureDoubleByte] = 0
                }
            }
        }
    }

    public init() {
        motion = .zero
        pressure = .zero
    }

    init(motion: UKMotionDataRates, pressure: UKPressureDataRates) {
        self.motion = motion
        self.pressure = pressure
    }

    // MARK: - Serialization

    func data(deviceType: UKDeviceType) -> Data {
        var data: Data = .init()

        UKSensorType.allCases.filter { deviceType.hasSensorType($0) }.forEach { sensorType in
            var subData: Data = .init()

            switch sensorType {
            case .motion:
                subData = motion.data
            case .pressure:
                subData = pressure.data
            }

            if subData.count > 0 {
                data.append(contentsOf: [sensorType.rawValue, UInt8(subData.count)])
                data.append(subData)
            }
        }
        return data
    }

    func data(deviceType: UKDeviceType, relativeTo reference: Self) -> Data {
        (self - reference).data(deviceType: deviceType)
    }

    // MARK: - Parsing

    init(from data: Data, at offset: inout Data.Index) {
        self.init()
        UKSensorType.allCases.forEach { sensorType in
            sensorType.forEachDataType { dataType in
                if offset + 2 <= data.count {
                    let dataRate: UKSensorDataRate = .parse(from: data, at: &offset)
                    switch sensorType {
                    case .motion:
                        if let motionDataType: UKMotionDataType = .init(rawValue: dataType) {
                            logger.debug("\(motionDataType.name): \(dataRate)")
                            motion[motionDataType] = dataRate
                        }
                    case .pressure:
                        if let pressureDataType: UKPressureDataType = .init(rawValue: dataType) {
                            logger.debug("\(pressureDataType.name): \(dataRate)")
                            pressure[pressureDataType] = dataRate
                        }
                    }
                }
                else {
                    logger.error("offset out of bounds")
                }
            }
        }
    }

    init(from data: Data) {
        var offset: Data.Index = 0
        self.init(from: data, at: &offset)
    }

    // MARK: - isZero

    var isZero: Bool {
        motion.isZero && pressure.isZero
    }

    // MARK: - Difference

    static func - (lhs: Self, rhs: Self) -> Self {
        .init(motion: lhs.motion - rhs.motion, pressure: lhs.pressure - rhs.pressure)
    }

    // MARK: - without zeros

    var withoutZeros: Self {
        .init(motion: motion.withoutZeros, pressure: pressure.withoutZeros)
    }

    // MARK: - min

    public static func min(_ lhs: UKSensorDataConfigurations, _ rhs: UKSensorDataConfigurations) -> UKSensorDataConfigurations {
        .init(motion: .min(lhs.motion, rhs.motion), pressure: .min(lhs.pressure, rhs.pressure))
    }
}
