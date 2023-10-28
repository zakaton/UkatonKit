import OSLog
import UkatonMacros

@StaticLogger
struct UKWifiInformationManager {
    // MARK: - SSID

    private var ssid: String? {
        didSet {
            onSsidUpdated?(password)
        }
    }

    public var onSsidUpdated: ((String?) -> Void)?

    mutating func parseSsid(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newSsid = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new wifi ssid \"\(newSsid)\"")
        ssid = newSsid
    }

    mutating func parseSsid(data: Data) {
        var offset: Data.Index = 0
        parseSsid(data: data, at: &offset, until: data.count)
    }

    // MARK: - Password

    private var password: String? {
        didSet {
            onPasswordUpdated?(password)
        }
    }

    public var onPasswordUpdated: ((String?) -> Void)?

    mutating func parsePassword(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newPassword = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new wifi password \"\(newPassword)\"")
        password = newPassword
    }

    mutating func parsePassword(data: Data) {
        var offset: Data.Index = 0
        parseSsid(data: data, at: &offset, until: data.count)
    }

    // MARK: - Connect

    private var shouldConnect: Bool? {
        didSet {
            onShouldConnectUpdated?(shouldConnect)
        }
    }

    public var onShouldConnectUpdated: ((Bool?) -> Void)?

    mutating func parseShouldConnect(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newShouldConnect: Bool = data.parse(at: &offset)
        logger.debug("new wifi should connect \"\(newShouldConnect)\"")
        shouldConnect = newShouldConnect
    }

    mutating func parseShouldConnect(data: Data) {
        var offset: Data.Index = 0
        parseShouldConnect(data: data, at: &offset, until: data.count)
    }

    // MARK: - Is Connected

    private var isConnected: Bool? {
        didSet {
            onConnectionUpdated?(isConnected)
        }
    }

    public var onConnectionUpdated: ((Bool?) -> Void)?

    mutating func parseIsConnected(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newIsConnected: Bool = data.parse(at: &offset)
        logger.debug("new wifi connection \"\(newIsConnected)\"")
        isConnected = newIsConnected
    }

    mutating func parseIsConnected(data: Data) {
        var offset: Data.Index = 0
        parseIsConnected(data: data, at: &offset, until: data.count)
    }

    // MARK: - Reset

    public mutating func reset() {
        logger.debug("resetting")
        ssid = nil
        password = nil
    }
}
