import Combine

public protocol UKCenterOfMassProvider: UKSensorDataConfigurable {
    var centerOfMassSubject: CurrentValueSubject<UKCenterOfMassData, Never> { get }
    func recalibrateCenterOfMass()
}
