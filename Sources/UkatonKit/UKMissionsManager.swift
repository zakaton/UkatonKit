import CoreBluetooth
import Foundation
import OSLog
import UkatonMacros

@Singleton(isMutable: true)
@StaticLogger
public struct UKMissionsManager {
    public var missions: [UKMission] = []
}
