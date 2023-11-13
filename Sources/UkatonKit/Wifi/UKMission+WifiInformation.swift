import Foundation

extension UKMission {
    // MARK: - Wifi SSID

    func parseWifiSsid(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newWifiSsid = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new wifi ssid \"\(newWifiSsid)\"")
        wifiSsid = newWifiSsid
    }

    func parseWifiSsid(data: Data, at offset: inout Data.Index) {
        parseWifiSsid(data: data, at: &offset, until: data.count)
    }

    func parseWifiSsid(data: Data) {
        var offset: Data.Index = 0
        parseWifiSsid(data: data, at: &offset, until: data.count)
    }

    // MARK: - Wifi Password

    func parseWifiPassword(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newWifiPassword = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new wifi password \"\(newWifiPassword)\"")
        wifiPassword = newWifiPassword
    }

    func parseWifiPassword(data: Data, at offset: inout Data.Index) {
        parseWifiPassword(data: data, at: &offset, until: data.count)
    }

    func parseWifiPassword(data: Data) {
        var offset: Data.Index = 0
        parseWifiPassword(data: data, at: &offset, until: data.count)
    }

    // MARK: - Wifi Connect

    func parseShouldConnectToWifi(data: Data, at offset: inout Data.Index) {
        let newShouldConnectToWifi: Bool = data.parse(at: &offset)
        logger.debug("new should connect to wifi \"\(newShouldConnectToWifi)\"")
        shouldConnectToWifi = newShouldConnectToWifi
    }

    func parseShouldConnectToWifi(data: Data) {
        var offset: Data.Index = 0
        parseShouldConnectToWifi(data: data, at: &offset)
    }

    // MARK: - Is Connected to Wifi

    func parseIsConnectedToWifi(data: Data, at offset: inout Data.Index) {
        let newIsConnectedToWifi: Bool = data.parse(at: &offset)
        logger.debug("updated is connected to wifi \"\(newIsConnectedToWifi)\"")
        isConnectedToWifi = newIsConnectedToWifi
    }

    func parseIsConnectedToWifi(data: Data) {
        var offset: Data.Index = 0
        parseIsConnectedToWifi(data: data, at: &offset)
    }

    // MARK: - IP Address

    func parseIpAddress(data: Data, at offset: inout Data.Index, until finalOffset: Data.Index) {
        let newIpAddress = data.parseString(offset: &offset, until: finalOffset)
        logger.debug("new ip address \"\(newIpAddress)\"")
        ipAddressSubject.send(newIpAddress)
    }

    func parseIpAddress(data: Data, at offset: inout Data.Index) {
        parseIpAddress(data: data, at: &offset, until: data.count)
    }

    func parseIpAddress(data: Data) {
        var offset: Data.Index = 0
        parseIpAddress(data: data, at: &offset, until: data.count)
    }
}
