import CoreBluetooth
import Foundation
import OSLog
import UkatonMacros

@Singleton
@StaticLogger
public class UKMissionsManager {
    @Published public private(set) var missions: [UKMission] = []

    func add(_ mission: UKMission) {
        if let index = missions.firstIndex(of: mission) {
            logger.debug("mission alreadyin at index \(index)")
            return
        }
        else {
            missions.append(mission)
            let _self = self
            logger.debug("added mission at index \(_self.missions.count - 1)")
        }
    }

    func remove(_ mission: UKMission) {
        if let index = missions.firstIndex(of: mission) {
            missions.remove(at: index)
            logger.debug("removed mission at index \(index)")
        }
        else {
            logger.warning("no mission found")
        }
    }
}
