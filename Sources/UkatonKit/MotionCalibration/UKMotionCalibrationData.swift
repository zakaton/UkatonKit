import Foundation
import OSLog
import StaticLogger

@StaticLogger
public struct UKMotionCalibrationData {
    // MARK: - Calibration

    private typealias Calibration = [UKMotionCalibrationType: UKMotionCalibrationTypeStatus]
    private var rawCalibration: Calibration = {
        var _calibration: Calibration = [:]
        UKMotionCalibrationType.allCases.forEach { motionCalibrationType in
            _calibration[motionCalibrationType] = .none
        }
        return _calibration
    }()

    public private(set) var isFullyCalibrated: Bool = false {
        didSet {
            if isFullyCalibrated, isFullyCalibrated != oldValue {
                logger.debug("fully calibrated")
                onFullyCalibrated?()
            }
        }
    }

    // MARK: - Conveniance Subscript

    public subscript(motionCalibrationType: UKMotionCalibrationType) -> UKMotionCalibrationTypeStatus {
        rawCalibration[motionCalibrationType]!
    }

    // MARK: - Callback

    public var onFullyCalibrated: (() -> Void)?

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout UInt8) {
        var newIsFullyCalibrated = true
        UKMotionCalibrationType.allCases.forEach { motionCalibrationType in
            let rawMotionCalibrationTypeStatus = data[Data.Index(offset)]
            offset += 1

            let motionCalibrationTypeStatus: UKMotionCalibrationTypeStatus = .init(rawValue: rawMotionCalibrationTypeStatus)!

            rawCalibration[motionCalibrationType] = motionCalibrationTypeStatus
            logger.debug("\(motionCalibrationType.name) calibration: \(motionCalibrationTypeStatus.name)")

            newIsFullyCalibrated = newIsFullyCalibrated && motionCalibrationTypeStatus == .high
        }

        isFullyCalibrated = newIsFullyCalibrated
    }
}
