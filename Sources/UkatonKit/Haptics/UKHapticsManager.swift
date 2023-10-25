import Foundation
import OSLog
import StaticLogger

@StaticLogger
struct UKHapticsManager {
    // MARK: - Serialization

    func serialize(waveforms: [UKVibrationWaveformType]) -> Data {
        var byteArray: [UInt8] = [UKVibrationType.waveform.rawValue]
        byteArray += waveforms.map { $0.rawValue }
        logger.debug("serialized waveforms: \(byteArray.debugDescription)")
        let data = Data(byteArray)
        return data
    }

    func serialize(sequence: [UKVibrationSequenceSegment]) -> Data {
        var byteArray: [UInt8] = [UKVibrationType.sequence.rawValue]
        byteArray += sequence.flatMap { $0.flat }
        logger.debug("serialized sequence: \(byteArray.debugDescription)")
        let data = Data(byteArray)
        return data
    }
}
