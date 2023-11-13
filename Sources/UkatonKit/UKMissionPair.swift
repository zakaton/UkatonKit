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
            if newHasBothInsoles != hasBothInsoles {
                hasBothInsolesSubject.send(newHasBothInsoles)
            }
        }
    }

    var hasBothInsoles: Bool { hasBothInsolesSubject.value }
    public let hasBothInsolesSubject = CurrentValueSubject<Bool, Never>(false)

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

    // MARK: - SensorData

    func onPressureValuesData(side: UKInsoleSide, data: (UKPressureValues, UKTimestamp)) {
        // TODO: - calculate
    }
}
