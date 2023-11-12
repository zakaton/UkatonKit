import Foundation

public typealias UKVibrationWaveformIntensity = Float
public typealias UKVibrationWaveformDelay = Float

public extension UKVibrationWaveformDelay {
    static var max: Self { 2560 }
    var max: Self { Self.max }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public struct UKVibrationWaveform: UKVibrationSequenceSegment {
    /// vibration intensity [0, 1]
    public var intensity: UKVibrationWaveformIntensity = 0 {
        didSet {
            intensity = intensity.clamped(to: 0 ... 1)
        }
    }

    /// vibration delay (ms) [0, 2560]
    public var delay: UKVibrationWaveformDelay = 0 {
        didSet {
            delay = delay.clamped(to: 0 ... .max).rounded()
        }
    }

    var bytes: [UInt8] {
        [UInt8(intensity * 126), UInt8(delay / 10)]
    }

    var data: Data {
        .init(bytes)
    }

    /// - Parameters:
    ///     - intensity: vibration intensity [0, 1]
    ///     - delay: vibration delay (ms)
    public init(intensity: UKVibrationWaveformIntensity, delay: UKVibrationWaveformDelay) {
        defer {
            self.intensity = intensity
            self.delay = delay
        }
    }
}
