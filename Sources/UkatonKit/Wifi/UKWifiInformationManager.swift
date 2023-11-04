import OSLog
import UkatonMacros

@StaticLogger
public struct UKWifiInformationManager {
    // MARK: - SSID

    public internal(set) var ssid: String? = nil

    mutating func parseSsid(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newSsid = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new wifi ssid \"\(newSsid)\"")
        ssid = newSsid
    }

    mutating func parseSsid(data: Data, at offset: inout Data.Index) {
        parseSsid(data: data, at: &offset, until: data.count)
    }

    mutating func parseSsid(data: Data) {
        var offset: Data.Index = 0
        parseSsid(data: data, at: &offset, until: data.count)
    }

    // MARK: - Password

    private var password: String? = nil

    mutating func parsePassword(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newPassword = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new wifi password \"\(newPassword)\"")
        password = newPassword
    }

    mutating func parsePassword(data: Data, at offset: inout Data.Index) {
        parsePassword(data: data, at: &offset, until: data.count)
    }

    mutating func parsePassword(data: Data) {
        var offset: Data.Index = 0
        parseSsid(data: data, at: &offset, until: data.count)
    }

    // MARK: - Connect

    private var shouldConnect: Bool? = nil

    mutating func parseShouldConnect(data: Data, at offset: inout Data.Index) {
        let newShouldConnect: Bool = data.parse(at: &offset)
        logger.debug("new wifi should connect \"\(newShouldConnect)\"")
        shouldConnect = newShouldConnect
    }

    mutating func parseShouldConnect(data: Data) {
        var offset: Data.Index = 0
        parseShouldConnect(data: data, at: &offset)
    }

    // MARK: - Is Connected

    var isConnected: Bool? = nil

    mutating func parseIsConnected(data: Data, at offset: inout Data.Index) {
        let newIsConnected: Bool = data.parse(at: &offset)
        logger.debug("new wifi connection \"\(newIsConnected)\"")
        isConnected = newIsConnected
    }

    mutating func parseIsConnected(data: Data) {
        var offset: Data.Index = 0
        parseIsConnected(data: data, at: &offset)
    }

    // MARK: - IP Address

    var ipAddress: String? = nil

    mutating func parseIpAddress(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newIpAddress = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new ip address \"\(newIpAddress)\"")
        ipAddress = newIpAddress
    }

    mutating func parseIpAddress(data: Data, at offset: inout Data.Index) {
        parseIpAddress(data: data, at: &offset, until: data.count)
    }

    mutating func parseIpAddress(data: Data) {
        var offset: Data.Index = 0
        parseIpAddress(data: data, at: &offset, until: data.count)
    }
}
