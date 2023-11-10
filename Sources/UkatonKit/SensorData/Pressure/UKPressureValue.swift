import Foundation
import simd

public struct UKPressureValue {
    public typealias Vector2D = simd_double2

    public internal(set) var rawValue: UInt16 = 0
    public internal(set) var weightedValue: Double = 0
    public internal(set) var normalizedValue: Double = 0
    public internal(set) var position: Vector2D = .init()
}
