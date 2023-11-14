import Foundation

public extension UKMission {
    // MARK: - RSSI

    func startReadingRssi() {
        guard let peripheral else {
            logger.error("not connected via bluetooth")
            return
        }
        guard readRssiTimer == nil else {
            logger.warning("already reading rssi")
            return
        }

        logger.debug("starting to read to rssi...")
        readRssiTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(readRSSI), userInfo: nil, repeats: true)
        isReadingRSSISubject.send(true)
    }

    func stopReadingRSSI() {
        guard let peripheral else {
            logger.error("not connected via bluetooth")
            return
        }
        guard readRssiTimer != nil else {
            logger.warning("not reading rssi")
            return
        }

        logger.debug("about to stop reading rssi...")

        readRssiTimer!.invalidate()
        readRssiTimer = nil
        isReadingRSSISubject.send(false)
    }

    func toggleReadingRSSI() {
        if readRssiTimer != nil {
            stopReadingRSSI()
        }
        else {
            startReadingRssi()
        }
    }

    @objc internal func readRSSI() throws {
        guard let peripheral else {
            logger.error("not connected via bluetooth")
            return
        }

        peripheral.readRSSI()
    }

    internal func parseBluetoothRSSI(_ data: Data, at offset: inout Data.Index) {
        let newRSSI: Int = .parse(from: data, at: &offset)
        logger.debug("new rssi: \(newRSSI.description)")
        rssiSubject.send(newRSSI)
    }
}
