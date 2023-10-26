import Foundation

protocol UKConnectionManager {
    var type: UKConnectionType { get }
    var status: UKConnectionStatus { get }

    // TODO: - get/set device info, sensor data, etc
}
