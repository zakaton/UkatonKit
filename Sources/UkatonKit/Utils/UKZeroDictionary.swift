import Foundation

// MARK: - for initializing UKSensorDataConfigurations

extension Dictionary where Key: CaseIterable & RawRepresentable, Key.RawValue: Numeric, Value: Numeric {
    static var zero: Self {
        var zero: Self = .init()
        Key.allCases.forEach { zero[$0] = .zero }
        return zero
    }

    var data: Data {
        var data: Data = .init()
        forEach { key, value in
            data.append(key.rawValue.data)
            data.append(value.data)
        }
        return data
    }
}

// MARK: - for initializing UKMotionCalibration

extension Dictionary where Key: CaseIterable & RawRepresentable, Key.RawValue: Numeric, Value: RawRepresentable, Value.RawValue: Numeric {
    static var zero: Self {
        var zero: Self = .init()
        Key.allCases.forEach { zero[$0] = .init(rawValue: .zero) }
        return zero
    }
}
