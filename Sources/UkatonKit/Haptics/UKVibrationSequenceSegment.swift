extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public struct UKVibrationSequenceSegment {
    /// vibration amplitude [0, 1]
    public var amplitude: Double {
        didSet {
            amplitude = amplitude.clamped(to: 0 ... 1)
        }
    }

    /// vibration delay (ms) [0, 2560]
    public var delay: UInt16 {
        didSet {
            delay = delay.clamped(to: 0 ... 2560)
        }
    }

    var flat: [UInt8] {
        [UInt8(amplitude * 126), UInt8(delay / 10)]
    }
}
