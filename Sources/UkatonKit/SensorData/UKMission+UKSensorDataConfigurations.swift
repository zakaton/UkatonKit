import Foundation

extension UKMission {
    // MARK: - Parsing

    func parseSensorDataConfigurations(_ data: Data, at offset: inout Data.Index) {
        sensorDataConfigurations.parse(data, at: &offset)
    }

    func parseSensorDataConfigurations(_ data: Data) {
        sensorDataConfigurations.parse(data)
    }
}
