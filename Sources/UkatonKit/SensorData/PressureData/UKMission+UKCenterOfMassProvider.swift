import Combine

extension UKMission: UKCenterOfMassProvider {
    public var centerOfMassSubject: CurrentValueSubject<UKCenterOfMassData, Never> {
        sensorData.pressure.centerOfMassSubject
    }

    public func recalibrateCenterOfMass() {
        sensorData.pressure.recalibrateCenterOfMass()
    }
}
