import Foundation
import UkatonMacros

@EnumName
public enum UKInsoleSide: UInt8, CaseIterable {
    case left
    case right
}

public struct UKMissionPair {
    // MARK: - Missions

    var missions: [UKInsoleSide: UKMission] = [:]
    subscript(side: UKInsoleSide) -> UKMission? {
        get {
            missions[side]
        }
        set {
            // TODO: - add listeners
        }
    }

    // MARK: - SensorData
}
