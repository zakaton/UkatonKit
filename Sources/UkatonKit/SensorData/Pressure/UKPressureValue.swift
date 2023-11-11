import Foundation
import simd

public typealias UKPressurePosition = simd_double2

public struct UKPressureValue: Identifiable {
    public var id: UKPressurePosition { position }

    public internal(set) var rawValue: UInt16 = 0
    public internal(set) var weightedValue: Double = 0
    public internal(set) var normalizedValue: Double = 0
    public internal(set) var position: UKPressurePosition = .init()
}
