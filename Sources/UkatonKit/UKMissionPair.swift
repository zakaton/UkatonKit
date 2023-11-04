import Foundation

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
