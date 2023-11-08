import Foundation
import UkatonMacros

@EnumName
enum UKVibrationType: UInt8 {
    case waveform
    case sequence
}

extension UKMission {
    func serializeHaptics(waveforms: [UKVibrationWaveformType]) -> Data {
        var byteArray: [UInt8] = [UKVibrationType.waveform.rawValue]
        byteArray += waveforms.map { $0.rawValue }
        logger.debug("serialized waveforms: \(byteArray.debugDescription)")
        let data = Data(byteArray)
        return data
    }

    func serializeHaptics(sequence: [UKVibrationSequenceSegment]) -> Data {
        var byteArray: [UInt8] = [UKVibrationType.sequence.rawValue]
        byteArray += sequence.flatMap { $0.flat }
        logger.debug("serialized sequence: \(byteArray.debugDescription)")
        let data = Data(byteArray)
        return data
    }
}
