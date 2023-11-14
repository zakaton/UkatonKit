import Combine
import Foundation
import OSLog
import UkatonMacros

@EnumName
public enum UKInsoleSide: UInt8, CaseIterable {
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

    private var missions: [UKInsoleSide: UKMission] = [:]
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
                mission.sensorData.pressure.pressureValuesSubject.sink(receiveValue: {
                    self.onPressureValuesData(side: side, data: $0)
                }).store(in: &cancellables[side]!)
            }

            let newHasBothInsoles = UKInsoleSide.allCases.allSatisfy { missions[$0] != nil }
            if newHasBothInsoles != isConnected {
                isConnectedSubject.send(newHasBothInsoles)
            }
        }
    }

    var isConnected: Bool { isConnectedSubject.value }
    public let isConnectedSubject = CurrentValueSubject<Bool, Never>(false)

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

    // MARK: - Data

    public var centerOfMass: UKCenterOfMass { centerOfMassSubject.value.value }
    public var mass: UKMass { massSubject.value.value }

    // MARK: - CurrentValueSubjects

    public let centerOfMassSubject = CurrentValueSubject<UKCenterOfMassData, Never>((.init(), 0))
    public let massSubject = CurrentValueSubject<UKMassData, Never>((.zero, 0))

    // MARK: - Parsing

    func onPressureValuesData(side: UKInsoleSide, data: UKPressureValuesData) {
        if isConnected {
            var newCenterOfMass: UKCenterOfMass = .init()
            var rawPressureValueSum: UKRawPressureValueSum = 0

            missions.forEach { _, mission in
                rawPressureValueSum += mission.sensorData.pressure.pressureValues.rawValueSum
            }

            logger.debug("rawPressureValueSum: \(rawPressureValueSum)")

            if rawPressureValueSum > 0 {
                missions.forEach { side, mission in
                    let rawValueSumWeight = Double(mission.sensorData.pressure.pressureValues.rawValueSum) / Double(rawPressureValueSum)

                    newCenterOfMass.y += mission.sensorData.pressure.centerOfMass.y * rawValueSumWeight
                    if side == .right {
                        newCenterOfMass.x = rawValueSumWeight
                    }
                }

                logger.debug("center of mass: \(newCenterOfMass.debugDescription)")
                centerOfMassSubject.send((newCenterOfMass, data.timestamp))
            }
        }
    }
}
