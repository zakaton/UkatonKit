import Foundation

extension UKMissionPair: UKSensorDataConfigurable {
    public func setSensorDataConfigurations(_ newSensorDataConfigurations: UKSensorDataConfigurations) throws {
        try missions.forEach { _, mission in
            try mission.setSensorDataConfigurations(newSensorDataConfigurations)
        }
    }
}
