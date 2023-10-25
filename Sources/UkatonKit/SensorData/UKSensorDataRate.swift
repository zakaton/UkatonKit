import Foundation

public typealias UKSensorDataRate = UInt16

extension UKSensorDataRate {
    func roundToTens() -> UKSensorDataRate {
        return self - (self % 10)
    }
}
