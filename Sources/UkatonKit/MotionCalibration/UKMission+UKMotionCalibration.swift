import Foundation

public typealias UKMotionCalibration = [UKMotionCalibrationType: UKMotionCalibrationStatus]

extension UKMission {
    func parseMotionCalibration(_ data: Data, at offset: inout Data.Index) {
        var newIsFullyCalibrated = true
        UKMotionCalibrationType.allCases.forEach { motionCalibrationType in
            let motionCalibrationTypeStatus = UKMotionCalibrationStatus(rawValue: data.parse(at: &offset))!

            motionCalibration[motionCalibrationType] = motionCalibrationTypeStatus
            logger.debug("\(motionCalibrationType.name) calibration: \(motionCalibrationTypeStatus.name)")

            newIsFullyCalibrated = newIsFullyCalibrated && motionCalibrationTypeStatus == .high
        }

        logger.debug("isFullyCalibrated? \(newIsFullyCalibrated)")
        isFullyCalibrated = newIsFullyCalibrated
    }

    func parseMotionCalibration(_ data: Data) {
        var offset: Data.Index = 0
        parseMotionCalibration(data, at: &offset)
    }
}
