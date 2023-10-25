import Foundation
import OSLog
import StaticLogger

public typealias UKMotionCalibrationData = [UKMotionCalibrationType: UKMotionCalibrationStatus]

@StaticLogger
public struct UKMotionCalibrationDataManager {
    // MARK: - Calibration

    public private(set) var calibration: UKMotionCalibrationData = {
        var _calibration: UKMotionCalibrationData = [:]
        UKMotionCalibrationType.allCases.forEach { motionCalibrationType in
            _calibration[motionCalibrationType] = .none
        }
        return _calibration
    }()

    public private(set) var isFullyCalibrated: Bool = false {
        didSet {
            onIsFullyCalibrated?(isFullyCalibrated)
        }
    }

    // MARK: - Conveniance Subscript

    public subscript(motionCalibrationType: UKMotionCalibrationType) -> UKMotionCalibrationStatus {
        calibration[motionCalibrationType]!
    }

    // MARK: - Callback

    public var onIsFullyCalibrated: ((Bool) -> Void)?

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout UInt8) {
        var newIsFullyCalibrated = true
        UKMotionCalibrationType.allCases.forEach { motionCalibrationType in
            let rawMotionCalibrationTypeStatus = data[Data.Index(offset)]
            offset += 1

            let motionCalibrationTypeStatus: UKMotionCalibrationStatus = .init(rawValue: rawMotionCalibrationTypeStatus)!

            calibration[motionCalibrationType] = motionCalibrationTypeStatus
            logger.debug("\(motionCalibrationType.name) calibration: \(motionCalibrationTypeStatus.name)")

            newIsFullyCalibrated = newIsFullyCalibrated && motionCalibrationTypeStatus == .high
        }

        logger.debug("isFullyCalibrated? \(newIsFullyCalibrated)")
        isFullyCalibrated = newIsFullyCalibrated
    }

    mutating func parse(_ data: Data) {
        var offset: UInt8 = 0
        parse(data, at: &offset)
    }
}
