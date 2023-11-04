import Foundation
import OSLog
import UkatonMacros

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

    public private(set) var isFullyCalibrated: Bool = false

    // MARK: - Conveniance Subscript

    public subscript(motionCalibrationType: UKMotionCalibrationType) -> UKMotionCalibrationStatus {
        calibration[motionCalibrationType]!
    }

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout Data.Index) {
        var newIsFullyCalibrated = true
        UKMotionCalibrationType.allCases.forEach { motionCalibrationType in
            let motionCalibrationTypeStatus = UKMotionCalibrationStatus(rawValue: data.parse(at: &offset))!

            calibration[motionCalibrationType] = motionCalibrationTypeStatus
            logger.debug("\(motionCalibrationType.name) calibration: \(motionCalibrationTypeStatus.name)")

            newIsFullyCalibrated = newIsFullyCalibrated && motionCalibrationTypeStatus == .high
        }

        logger.debug("isFullyCalibrated? \(newIsFullyCalibrated)")
        isFullyCalibrated = newIsFullyCalibrated
    }

    mutating func parse(_ data: Data) {
        var offset: Data.Index = 0
        parse(data, at: &offset)
    }
}
