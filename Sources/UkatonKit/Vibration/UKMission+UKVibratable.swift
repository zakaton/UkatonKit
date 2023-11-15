extension UKMission: UKVibratable {
    public func vibrate(waveformEffects: [UKVibrationWaveformEffect]) throws {
        try sendMessage(type: .triggerVibration, data: serializeVibration(waveformEffects: waveformEffects))
    }

    public func vibrate(waveforms: [UKVibrationWaveform]) throws {
        try sendMessage(type: .triggerVibration, data: serializeVibration(waveforms: waveforms))
    }
}
