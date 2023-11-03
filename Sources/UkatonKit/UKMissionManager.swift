import CoreBluetooth
import Foundation
import OSLog
import UkatonMacros

@Singleton
@StaticLogger
public class UKMissionManager {
    @Published public var missions: [UKMission] = []
}
