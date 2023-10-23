import Foundation
import simd

public struct UKPressureValue {
    public typealias Vector2D = simd_double2

    public var rawValue: UInt16 = 0
    public var weightedValue: Double = 0
    public var normalizedValue: Double = 0
    public var position: Vector2D = .init()
}
