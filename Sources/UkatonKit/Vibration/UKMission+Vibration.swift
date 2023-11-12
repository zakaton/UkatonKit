import Foundation
import UkatonMacros

@EnumName
enum UKVibrationType: UInt8 {
    case waveform
    case sequence
}

extension UKMission {
    func serializeVibration(waveforms: [UKVibrationWaveform]) -> Data {
        var byteArray: [UInt8] = [UKVibrationType.waveform.rawValue]
        byteArray += waveforms.map { $0.rawValue }
        logger.debug("serialized waveforms vibration: \(byteArray.debugDescription)")
        let data = Data(byteArray)
        return data
    }

    func serializeVibration(sequence: [UKVibrationSequenceSegment]) -> Data {
        var byteArray: [UInt8] = [UKVibrationType.sequence.rawValue]
        byteArray += sequence.flatMap { $0.bytes }
        logger.debug("serialized sequence vibration: \(byteArray.debugDescription)")
        let data = Data(byteArray)
        return data
    }
}
