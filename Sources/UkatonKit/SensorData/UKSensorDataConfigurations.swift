import Foundation
import OSLog
import UkatonMacros

public typealias UKMotionDataRates = [UKMotionDataType: UKSensorDataRate]
public typealias UKPressureDataRates = [UKPressureDataType: UKSensorDataRate]

@StaticLogger
public struct UKSensorDataConfigurations {
    public var motion: UKMotionDataRates = {
        var dataRates: UKMotionDataRates = .init()
        UKMotionDataType.allCases.forEach { dataType in dataRates[dataType] = 0 }
        return dataRates
    }()

    public var pressure: UKPressureDataRates = {
        var dataRates: UKPressureDataRates = .init()
        UKPressureDataType.allCases.forEach { dataType in dataRates[dataType] = 0 }
        return dataRates
    }()

    public init() {}

    // MARK: - Serialization

    func data(deviceType: UKDeviceType = .motionModule) -> Data {
        var data: Data = .init()

        UKSensorType.allCases.filter { deviceType.hasSensorType($0) }.forEach { sensorType in
            var subData: Data = .init()
            switch sensorType {
            case .motion:
                motion.forEach { dataType, dataRate in
                    subData.append(dataType.rawValue.data)
                    subData.append(dataRate.data)
                }
            case .pressure:
                pressure.forEach { dataType, dataRate in
                    subData.append(dataType.rawValue.data)
                    subData.append(dataRate.data)
                }
            }

            if subData.count > 0 {
                data.append(contentsOf: [sensorType.rawValue, UInt8(subData.count)])
                data.append(subData)
            }
        }
        return data
    }

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout Data.Index) {
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

    mutating func parse(_ data: Data) {
        var offset: Data.Index = 0
        parse(data, at: &offset)
    }
}
