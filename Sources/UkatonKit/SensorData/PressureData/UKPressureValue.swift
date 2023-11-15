import Foundation
import simd

public typealias UKRawPressureValue = UInt16
public typealias UKWeightedPressureValue = Double
public typealias UKNormalizedPressureValue = Double
public typealias UKPressurePosition = simd_double2

public struct UKPressureValue: Identifiable {
    public var id: UKPressurePosition { position }

    public internal(set) var rawValue: UKRawPressureValue = 0
    public internal(set) var weightedValue: UKWeightedPressureValue = 0
    public internal(set) var normalizedValue: UKNormalizedPressureValue = 0
    public internal(set) var position: UKPressurePosition = .init()
}
