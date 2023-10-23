import Foundation
import simd

public struct PressureValues {
    static let pressurePositions: [PressureValue.Vector2D] = [
        .init(x: 0.6385579634772724, y: 0.12185506415310729),
        .init(x: 0.3549331417480725, y: 0.15901519981589698),
        .init(x: 0.7452523671145329, y: 0.20937944459744443),
        .init(x: 0.4729939843657848, y: 0.24446464882728644),
        .init(x: 0.21767802953129523, y: 0.27125012732533793),
        .init(x: 0.6841309499554993, y: 0.305958071294644),
        .init(x: 0.4443634258018164, y: 0.34255231656662977),
        .init(x: 0.2058826683251659, y: 0.3878235478309421),
        .init(x: 0.5179235875054955, y: 0.4515805318615153),
        .init(x: 0.19087039042645593, y: 0.49232463999939635),
        .init(x: 0.4643083092958169, y: 0.6703914829723581),
        .init(x: 0.19301500155484305, y: 0.6677506611486066),
        .init(x: 0.4643083092958169, y: 0.7567840826350875),
        .init(x: 0.19301500155484305, y: 0.7545205210718718),
        .init(x: 0.46645292042420405, y: 0.9129698304969649),
        .init(x: 0.19891268215790772, y: 0.9133470907575008)
    ]

    // MARK: - DeviceType

    var deviceType: DeviceType? {
        didSet {
            if let deviceType, deviceType != oldValue {
                // TODO: - update pressure positions
                if deviceType.isInsole == true {
                    for index in 0 ..< numberOfPressureSensors {
                        rawValues[index].position = Self.pressurePositions[index]
                        if deviceType.insoleSide == .right {
                            rawValues[index].position.x = 1 - rawValues[index].position.x
                        }
                    }
                }
            }
        }
    }

    // MARK: - Data Scalar

    typealias Scalars = [PressureDataType: Double]
    static let scalars: Scalars = [
        .pressureSingleByte: pow(2.0, -8.0),
        .pressureDoubleByte: pow(2.0, -12.0)
    ]
    var scalars: Scalars { Self.scalars }

    // MARK: - Raw Values

    static let numberOfPressureSensors: Int = 16
    var numberOfPressureSensors: Int { Self.numberOfPressureSensors }
    private var rawValues: [PressureValue] = .init(repeating: .init(), count: numberOfPressureSensors)
    public subscript(index: Int) -> PressureValue {
        rawValues[index]
    }

    // MARK: - Derived Values

    public typealias Vector2D = simd_double2

    public private(set) var centerOfMass: Vector2D = .init()
    public private(set) var mass: Double = .zero
    public private(set) var heelToToe: Float64 = .zero

    // MARK: - Parsing

    mutating func parse(_ data: Data, at offset: inout UInt8, for pressureDataType: PressureDataType) {
        let scalar = scalars[pressureDataType]!
        // TODO: - FILL
    }
}
