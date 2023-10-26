import Foundation
import Network

class UKUdpManager: UKConnectionManager {
    let type: UKConnectionType = .udp
    var status: UKConnectionStatus = .notConnected
}
