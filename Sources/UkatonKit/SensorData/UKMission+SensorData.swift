import Foundation

extension UKMission {
    func startCheckingSensorData() {
        guard checkSensorDataTimer == nil else {
            logger.warning("timer is already running")
            return
        }
        logger.debug("starting sensorDataCheck")
        checkSensorDataTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkSensorData), userInfo: nil, repeats: true)
        checkSensorDataTimer?.tolerance = 0.2
    }

    func stopCheckingSensorData() {
        guard checkSensorDataTimer != nil else {
            logger.warning("no timer to stop")
            return
        }

        logger.debug("stopping sensorData check")
        checkSensorDataTimer!.invalidate()
        checkSensorDataTimer = nil
    }

    func updateCheckSensorDataTimer() {
        if connectionType?.requiresWifi == true {
            if sensorDataConfigurationsSubject.value.isZero {
                stopCheckingSensorData()
            }
            else {
                startCheckingSensorData()
            }
        }
    }

    @objc func checkSensorData() throws {
        if sensorData.lastTimeReceivedSensorData.timeIntervalSinceNow < -1 {
            logger.debug("resending sensorDataConfigurations")
            try? resendSensorDataConfigurations()
        }
    }
}
