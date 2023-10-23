public enum MotionCalibrationTypeStatus: UInt8 {
    case unreliable
    case low
    case medium
    case high

    var name: String {
        switch self {
        case .unreliable:
            "Unreliable"
        case .low:
            "Accuracy Low"
        case .medium:
            "Accuracy Medium"
        case .high:
            "Accuracy High"
        }
    }
}
