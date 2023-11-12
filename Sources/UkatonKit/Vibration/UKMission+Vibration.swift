import Foundation
import UkatonMacros

@EnumName
public enum UKVibrationType: UInt8 {
    case waveformEffect
    case waveform

    public var maxSequenceLength: Int {
        switch self {
        case .waveformEffect:
            8
        case .waveform:
            20
        }
    }
}

protocol UKVibrationSequenceSegment {
    var data: Data { get }
}

extension UKMission {
    func serializeVibration(waveformEffects: [UKVibrationWaveformEffect]) -> Data {
        serializeVibration(type: .waveformEffect, sequence: waveformEffects)
    }

    func serializeVibration(waveforms: [UKVibrationWaveform]) -> Data {
        serializeVibration(type: .waveform, sequence: waveforms)
    }

    fileprivate func serializeVibration(type: UKVibrationType, sequence: [UKVibrationSequenceSegment]) -> Data {
        var data: Data = .init()
        data.append(contentsOf: [type.rawValue])
        data += sequence.prefix(type.maxSequenceLength).flatMap { $0.data }
        logger.debug("serialized \(type.name) vibration: \(data.debugDescription)")
        return data
    }
}
