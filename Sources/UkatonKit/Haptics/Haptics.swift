import Foundation

struct Haptics {
    func serializeWaveforms(waveforms: [VibrationWaveformType]) -> Data {
        let byteArray: [UInt8] = []
        // FILL
        let data = Data(byteArray)
        return data
    }

    func serializeSequence(sequence: [VibrationSequenceSegment]) -> Data {
        let byteArray: [UInt8] = []
        // FILL
        let data = Data(byteArray)
        return data
    }
}
