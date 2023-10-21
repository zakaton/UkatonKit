import Foundation

@propertyWrapper
struct SensorDataRate {
    private var rate: UInt16 = 0
    var wrappedValue: UInt16 {
        get { return rate }
        set { rate = roundToTens(newValue) }
    }

    init(rate: UInt16) {
        self.rate = rate
    }

    private func roundToTens(_ value: UInt16) -> UInt16 {
        value - (value % 10)
    }
}
