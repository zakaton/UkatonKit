public protocol UKVibratable {
    func vibrate(waveformEffects: [UKVibrationWaveformEffect]) throws
    func vibrate(waveforms: [UKVibrationWaveform]) throws
}

public extension UKVibratable {
    func vibrate(waveformEffect: UKVibrationWaveformEffect) throws {
        try vibrate(waveformEffects: [waveformEffect])
    }

    func vibrate(waveform: UKVibrationWaveform) throws {
        try vibrate(waveforms: [waveform])
    }
}
