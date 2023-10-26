import Foundation
import Network

class UKUdpConnectionManager: UKConnectionManager {
    let type: UKConnectionType = .udp
    var status: UKConnectionStatus = .notConnected
}
