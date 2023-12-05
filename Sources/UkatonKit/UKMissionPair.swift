import Combine
import Foundation
import OSLog
import UkatonMacros

@EnumName
public enum UKInsoleSide: UInt8, CaseIterable, Identifiable {
    public var id: UInt8 { rawValue }
    case left
    case right
}

typealias UKInsoleCancellables = [UKInsoleSide: Set<AnyCancellable>]

@Singleton
@StaticLogger
public class UKMissionPair: ObservableObject {
    // MARK: - Missions

    private var cancellables: UKInsoleCancellables = {
        var _cancelleables: UKInsoleCancellables = [:]
        UKInsoleSide.allCases.forEach { _cancelleables[$0] = .init() }
        return _cancelleables
    }()

    private(set) var missions: [UKInsoleSide: UKMission] = [:]
    public private(set) subscript(side: UKInsoleSide) -> UKMission? {
        get {
            missions[side]
        }
        set {
            guard newValue != missions[side] else { return }

            if missions[side] != nil {
                let mission = missions[side]!
                cancellables[side]!.removeAll()
            }

            missions[side] = newValue

            if let mission = newValue {
                mission.sensorData.pressure.pressureValuesSubject.sink(receiveValue: { [weak self] in
                    self?.onPressureValuesData(side: side, data: $0)
                }).store(in: &cancellables[side]!)
                mission.sensorDataConfigurationsSubject.sink(receiveValue: { [weak self] in
                    // TODO: - what's a better way to indicate configuration?
                    self?.sensorDataConfigurationsSubject.send($0)
                    // self?.sensorDataConfigurationsSubject.send(self!.minSensorDataConfiguraions)
                }).store(in: &cancellables[side]!)
            }

            let newHasBothInsoles = UKInsoleSide.allCases.allSatisfy { missions[$0] != nil }
            isConnected = newHasBothInsoles
        }
    }

    // MARK: - Connection

    @Published public private(set) var isConnected: Bool = false
    public var isHalfConnected: Bool {
        guard !isConnected else { return false }

        return missions[.left] != nil || missions[.right] != nil
    }

    // MARK: - Add/Remove

    public func add(mission: UKMission, overwrite: Bool = false) {
        if let insoleSide = mission.deviceType.insoleSide {
            if self[insoleSide] == nil || overwrite {
                logger.debug("adding \(insoleSide.name) mission")
                self[insoleSide] = mission
            }
            else {
                logger.debug("a \(insoleSide.name) mission was already added")
            }
        }
    }

    public func remove(mission: UKMission) {
        if let insoleSide = mission.deviceType.insoleSide {
            if self[insoleSide] == mission {
                logger.debug("removing \(insoleSide.name) mission")
                self[insoleSide] = nil
            }
        }
    }

    // MARK: Sensor Data Configurations

    public let sensorDataConfigurationsSubject = CurrentValueSubject<UKSensorDataConfigurations, Never>(.init())
    public var sensorDataConfigurations: UKSensorDataConfigurations { sensorDataConfigurationsSubject.value }
    var minSensorDataConfiguraions: UKSensorDataConfigurations {
        guard let leftMission = missions[.left], let rightMission = missions[.right] else {
            logger.error("missions aren't connected")
            return .init()
        }
        return .min(leftMission.sensorDataConfigurations, rightMission.sensorDataConfigurations)
    }

    // MARK: - Pressure Data

    public var centerOfMass: UKCenterOfMass { centerOfMassSubject.value.value }
    public let centerOfMassSubject = CurrentValueSubject<UKCenterOfMassData, Never>((.init(), 0))

    public var mass: UKMass { massSubject.value.value }
    public let massSubject = CurrentValueSubject<UKMassData, Never>((.zero, 0))

    // MARK: - Normalization

    var lowerCenterOfMass: UKCenterOfMass = .init(x: .infinity, y: .infinity)
    var upperCenterOfMass: UKCenterOfMass = .init(x: -.infinity, y: -.infinity)
    public func recalibrateCenterOfMass() {
        lowerCenterOfMass = .init(x: .infinity, y: .infinity)
        upperCenterOfMass = .init(x: -.infinity, y: -.infinity)
    }

    func updateCenterOfMassRange(with centerOfMass: UKCenterOfMass) {
        lowerCenterOfMass.x = min(lowerCenterOfMass.x, centerOfMass.x)
        lowerCenterOfMass.y = min(lowerCenterOfMass.y, centerOfMass.y)

        upperCenterOfMass.x = max(upperCenterOfMass.x, centerOfMass.x)
        upperCenterOfMass.y = max(upperCenterOfMass.y, centerOfMass.y)
    }

    func normalizeCenterOfMass(_ centerOfMass: inout UKCenterOfMass) {
        centerOfMass.x = getInterpolation(of: centerOfMass.x, between: lowerCenterOfMass.x, and: upperCenterOfMass.x)
        centerOfMass.y = getInterpolation(of: centerOfMass.y, between: lowerCenterOfMass.y, and: upperCenterOfMass.y)
    }

    // MARK: - Parsing

    var bothPressureValues: [UKInsoleSide: UKPressureValues] = [:]
    var hasBothPressureValues: Bool {
        bothPressureValues.count == UKInsoleSide.allCases.count
    }

    func onPressureValuesData(side: UKInsoleSide, data: UKPressureValuesData) {
        bothPressureValues[side] = data.value
        if isConnected, hasBothPressureValues {
            var newCenterOfMass: UKCenterOfMass = .init()
            var massSum: UKMass = 0

            bothPressureValues.forEach { _, pressureValues in
                massSum += pressureValues.mass
            }

            logger.debug("massSum: \(massSum)")

            if massSum > 0 {
                bothPressureValues.forEach { side, pressureValues in
                    let massSumWeight = pressureValues.mass / massSum

                    newCenterOfMass.y += pressureValues.centerOfMass.y * massSumWeight
                    if side == .right {
                        newCenterOfMass.x = massSumWeight
                    }
                }

                updateCenterOfMassRange(with: newCenterOfMass)
                normalizeCenterOfMass(&newCenterOfMass)

                logger.debug("center of mass: \(newCenterOfMass.debugDescription)")
                centerOfMassSubject.send((newCenterOfMass, data.timestamp))
            }
        }
    }
}

extension UKMissionPair: UKCenterOfMassProvider {}
