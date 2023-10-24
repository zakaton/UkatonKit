enum UKVibrationType: UInt8 {
    case waveform
    case sequence

    var name: String {
        switch self {
        case .waveform:
            "waveform"
        case .sequence:
            "sequence"
        }
    }
}
