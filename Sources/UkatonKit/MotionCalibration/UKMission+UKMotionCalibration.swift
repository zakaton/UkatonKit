import Foundation

public typealias UKMotionCalibration = [UKMotionCalibrationType: UKMotionCalibrationStatus]

public extension UKMotionCalibration {
    static var empty: Self { .zero }
}

extension UKMission {
    func parseMotionCalibration(_ data: Data, at offset: inout Data.Index) {
        var newIsMotionFullyCalibrated = true
        var newMotionCalibration: UKMotionCalibration = .zero
        UKMotionCalibrationType.allCases.forEach { motionCalibrationType in
            let motionCalibrationTypeStatus = UKMotionCalibrationStatus(rawValue: data.parse(at: &offset))!

            newMotionCalibration[motionCalibrationType] = motionCalibrationTypeStatus
            logger.debug("\(motionCalibrationType.name) calibration: \(motionCalibrationTypeStatus.name)")

            newIsMotionFullyCalibrated = newIsMotionFullyCalibrated && motionCalibrationTypeStatus == .high
        }

        motionCalibrationSubject.send(newMotionCalibration)

        logger.debug("isMotionFullyCalibrated? \(newIsMotionFullyCalibrated)")
        if newIsMotionFullyCalibrated != isMotionFullyCalibrated {
            isMotionFullyCalibratedSubject.send(newIsMotionFullyCalibrated)
        }
    }

    func parseMotionCalibration(_ data: Data) {
        var offset: Data.Index = 0
        parseMotionCalibration(data, at: &offset)
    }
}
