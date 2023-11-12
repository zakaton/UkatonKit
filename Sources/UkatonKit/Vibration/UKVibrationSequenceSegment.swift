extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public struct UKVibrationSequenceSegment {
    /// vibration intensity [0, 1]
    public var intensity: Double = 0 {
        didSet {
            intensity = intensity.clamped(to: 0 ... 1)
        }
    }

    /// vibration delay (ms) [0, 2560]
    public var delay: UInt16 = 0 {
        didSet {
            delay = delay.clamped(to: 0 ... 2560)
        }
    }

    var bytes: [UInt8] {
        [UInt8(intensity * 126), UInt8(delay / 10)]
    }

    /// - Parameters:
    ///     - intensity: vibration intensity [0, 1]
    ///     - delay: vibration delay (ms)
    init(intensity: Double, delay: UInt16) {
        defer {
            self.intensity = intensity
            self.delay = delay
        }
    }
}
