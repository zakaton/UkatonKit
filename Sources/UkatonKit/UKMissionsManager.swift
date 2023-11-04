import CoreBluetooth
import Foundation
import OSLog
import UkatonMacros

@Singleton
@StaticLogger
public class UKMissionsManager {
    @Published public internal(set) var missions: [UKMission] = []
}
