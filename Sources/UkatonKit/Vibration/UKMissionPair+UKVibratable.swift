extension UKMissionPair: UKVibratable {
    public func vibrate(waveformEffects: [UKVibrationWaveformEffect]) throws {
        try missions.forEach { _, mission in
            try mission.vibrate(waveformEffects: waveformEffects)
        }
    }

    public func vibrate(waveforms: [UKVibrationWaveform]) throws {
        try missions.forEach { _, mission in
            try mission.vibrate(waveforms: waveforms)
        }
    }
}
