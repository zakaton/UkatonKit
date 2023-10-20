import Foundation

struct HapticsManager {
    func serializeWaveforms(waveforms: [VibrationWaveformType]) -> Data {
        let byteArray: [UInt8] = []
        let data = Data(byteArray)
        return data
    }

    func serializeSequence(sequence: [VibrationSequenceSegment]) -> Data {
        let byteArray: [UInt8] = []
        let data = Data(byteArray)
        return data
    }
}
