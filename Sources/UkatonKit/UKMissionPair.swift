import Combine
import Foundation
import OSLog
import UkatonMacros

@EnumName
public enum UKInsoleSide: UInt8, CaseIterable {
    case left
    case right
}

@Singleton
@StaticLogger
public class UKMissionPair: ObservableObject {
    // MARK: - Missions

    private var missions: [UKInsoleSide: UKMission] = [:]
    public private(set) subscript(side: UKInsoleSide) -> UKMission? {
        get {
            missions[side]
        }
        set {
            // TODO: - add listeners
            missions[side] = newValue

            let newHasBothInsoles = UKInsoleSide.allCases.allSatisfy { missions[$0] != nil }
            if newHasBothInsoles != hasBothInsoles {
                hasBothInsolesSubject.send(newHasBothInsoles)
            }
        }
    }

    var hasBothInsoles: Bool { hasBothInsolesSubject.value }
    public let hasBothInsolesSubject = CurrentValueSubject<Bool, Never>(false)

    public func add(mission: UKMission, overwrite: Bool = false) {
        if let insoleSide = mission.deviceType.insoleSide {
            if self[insoleSide] == nil || overwrite {
                logger.debug("adding \(insoleSide.name) mission")
                self[insoleSide] = mission
            }
            else {
                logger.debug("a \(insoleSide.name) mission was already added")
            }
        }
    }

    public func remove(mission: UKMission) {
        if let insoleSide = mission.deviceType.insoleSide {
            if self[insoleSide] == mission {
                logger.debug("removing \(insoleSide.name) mission")
                self[insoleSide] = nil
            }
        }
    }

    // MARK: - SensorData
}
