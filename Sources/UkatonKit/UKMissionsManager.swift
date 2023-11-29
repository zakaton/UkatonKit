import Combine
import CoreBluetooth
import Foundation
import OSLog
import UkatonMacros

@Singleton
@StaticLogger
public class UKMissionsManager: ObservableObject {
    @Published public private(set) var missions: [UKMission] = []
    public let missionAddedSubject = PassthroughSubject<UKMission, Never>()

    let missionPair: UKMissionPair = .shared

    func add(_ mission: UKMission) {
        if let index = missions.firstIndex(of: mission) {
            logger.debug("mission already in at index \(index)")
            return
        }
        else {
            missions.append(mission)
            missionPair.add(mission: mission)
            missionAddedSubject.send(mission)
            let _self = self
            logger.debug("added mission at index \(_self.missions.count - 1)")
        }
    }

    func remove(_ mission: UKMission) {
        if let index = missions.firstIndex(of: mission) {
            missionPair.remove(mission: mission)
            missions.remove(at: index)
            logger.debug("removed mission at index \(index)")
        }
        else {
            logger.warning("no mission found")
        }
    }
}
