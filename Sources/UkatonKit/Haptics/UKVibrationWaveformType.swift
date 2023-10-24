/// Based on [DRV2605 Haptic Driver, section 11.2](https://www.ti.com/lit/ds/symlink/drv2605.pdf)
public enum UKVibrationWaveformType: UInt8 {
    case none = 0 // None

    case strongClick100 = 1 // Strong Click - 100%
    case strongClick60 = 2 // Strong Click - 60%
    case strongClick30 = 3 // Strong Click - 30%

    case sharpClick100 = 4 // Sharp Click - 100%
    case sharpClick60 = 5 // Sharp Click - 60%
    case sharpClick30 = 6 // Sharp Click - 30%

    case softBump100 = 7 // Soft Bump - 100%
    case softBump60 = 8 // Soft Bump - 60%
    case softBump30 = 9 // Soft Bump - 30%

    case doubleClick100 = 10 // Double Click - 100%
    case doubleClick60 = 11 // Double Click - 60%

    case tripleClick100 = 12 // Triple Click - 100%

    case softFuzz60 = 13 // Soft Fuzz - 60%

    case strongBuzz100 = 14 // Strong Buzz - 100%

    case alert750ms = 15 // 750 ms Alert - 100%
    case alert1000ms = 16 // 1000 ms Alert - 100%

    case strongClick1_100 = 17 // Strong Click 1 - 100%
    case strongClick2_80 = 18 // Strong Click 2 - 80%
    case strongClick3_60 = 19 // Strong Click 3 - 60%
    case strongClick4_30 = 20 // Strong Click 4 - 30%

    case mediumClick100 = 21 // Medium Click 1 - 100%
    case mediumClick80 = 22 // Medium Click 2 - 80%
    case mediumClick60 = 23 // Medium Click 3 - 60%

    case sharpTick100 = 24 // Sharp Tick 1 - 100%
    case sharpTick80 = 25 // Sharp Tick 2 - 80%
    case sharpTick60 = 26 // Sharp Tick 3 - 60%

    case shortDoubleClickStrong100 = 27 // Short Double Click Strong 1 - 100%
    case shortDoubleClickStrong80 = 28 // Short Double Click Strong 2 - 80%
    case shortDoubleClickStrong60 = 29 // Short Double Click Strong 3 - 60%
    case shortDoubleClickStrong30 = 30 // Short Double Click Strong 4 - 30%

    case shortDoubleClickMedium100 = 31 // Short Double Click Medium 1 - 100%
    case shortDoubleClickMedium80 = 32 // Short Double Click Medium 2 - 80%
    case shortDoubleClickMedium60 = 33 // Short Double Click Medium 3 - 60%

    case shortDoubleSharpTick100 = 34 // Short Double Sharp Tick 1 - 100%
    case shortDoubleSharpTick80 = 35 // Short Double Sharp Tick 2 - 80%
    case shortDoubleSharpTick60 = 36 // Short Double Sharp Tick 3 - 60%

    case longDoubleSharpClickStrong100 = 37 // Long Double Sharp Click Strong 1 - 100%
    case longDoubleSharpClickStrong80 = 38 // Long Double Sharp Click Strong 2 - 80%
    case longDoubleSharpClickStrong60 = 39 // Long Double Sharp Click Strong 3 - 60%
    case longDoubleSharpClickStrong30 = 40 // Long Double Sharp Click Strong 4 - 30%

    case longDoubleSharpClickMedium100 = 41 // Long Double Sharp Click Medium 1 - 100%
    case longDoubleSharpClickMedium80 = 42 // Long Double Sharp Click Medium 2 - 80%
    case longDoubleSharpClickMedium60 = 43 // Long Double Sharp Click Medium 3 - 60%

    case longDoubleSharpTick100 = 44 // Long Double Sharp Tick 1 - 100%
    case longDoubleSharpTick80 = 45 // Long Double Sharp Tick 2 - 80%
    case longDoubleSharpTick60 = 46 // Long Double Sharp Tick 3 - 60%

    case buzz100 = 47 // Buzz 1 - 100%
    case buzz80 = 48 // Buzz 2 - 80%
    case buzz60 = 49 // Buzz 3 - 60%
    case buzz40 = 50 // Buzz 4 - 40%
    case buzz20 = 51 // Buzz 5 - 20%

    case pulsingStrong100 = 52 // Pulsing Strong 1 - 100%
    case pulsingStrong60 = 53 // Pulsing Strong 2 - 60%

    case pulsingMedium100 = 54 // Pulsing Medium 1 - 100%
    case pulsingMedium60 = 55 // Pulsing Medium 2 - 60%

    case pulsingSharp100 = 56 // Pulsing Sharp 1 - 100%
    case pulsingSharp60 = 57 // Pulsing Sharp 2 - 60%

    case transitionClick100 = 58 // Transition Click 1 - 100%
    case transitionClick80 = 59 // Transition Click 2 - 80%
    case transitionClick60 = 60 // Transition Click 3 - 60%
    case transitionClick40 = 61 // Transition Click 4 - 40%
    case transitionClick20 = 62 // Transition Click 5 - 20%
    case transitionClick10 = 63 // Transition Click 6 - 10%

    case transitionHum100 = 64 // Transition Hum 1 - 100%
    case transitionHum80 = 65 // Transition Hum 2 - 80%
    case transitionHum60 = 66 // Transition Hum 3 - 60%
    case transitionHum40 = 67 // Transition Hum 4 - 40%
    case transitionHum20 = 68 // Transition Hum 5 - 20%
    case transitionHum10 = 69 // Transition Hum 6 - 10%

    case transitionRampDownLongSmooth2_100 = 70 // Transition Ramp Down Long Smooth 2 - 100 to 0%
    case transitionRampDownLongSmooth1_100 = 71 // Transition Ramp Down Long Smooth 1 - 100 to 0%

    case transitionRampDownMediumSmooth1_100 = 72 // Transition Ramp Down Medium Smooth 1 - 100 to 0%
    case transitionRampDownMediumSmooth2_100 = 73 // Transition Ramp Down Medium Smooth 2 - 100 to 0%

    case transitionRampDownShortSmooth1_100 = 74 // Transition Ramp Down Short Smooth 1 - 100 to 0%
    case transitionRampDownShortSmooth2_100 = 75 // Transition Ramp Down Short Smooth 2 - 100 to 0%

    case transitionRampDownLongSharp1_100 = 76 // Transition Ramp Down Long Sharp 1 - 100 to 0%
    case transitionRampDownLongSharp2_100 = 77 // Transition Ramp Down Long Sharp 2 - 100 to 0%

    case transitionRampDownMediumSharp1_100 = 78 // Transition Ramp Down Medium Sharp 1 - 100 to 0%
    case transitionRampDownMediumSharp2_100 = 79 // Transition Ramp Down Medium Sharp 2 - 100 to 0%

    case transitionRampDownShortSharp1_100 = 80 // Transition Ramp Down Short Sharp 1 - 100 to 0%
    case transitionRampDownShortSharp2_100 = 81 // Transition Ramp Down Short Sharp 2 - 100 to 0%

    case transitionRampUpLongSmooth1_100 = 82 // Transition Ramp Up Long Smooth 1 - 100 to 0%
    case transitionRampUpLongSmooth2_100 = 83 // Transition Ramp Up Long Smooth 2 - 100 to 0%

    case transitionRampUpMediumSmooth1_100 = 84 // Transition Ramp Up Medium Smooth 1 - 100 to 0%
    case transitionRampUpMediumSmooth2_100 = 85 // Transition Ramp Up Medium Smooth 2 - 100 to 0%

    case transitionRampUpShortSmooth1_100 = 86 // Transition Ramp Up Short Smooth 1 - 100 to 0%
    case transitionRampUpShortSmooth2_100 = 87 // Transition Ramp Up Short Smooth 2 - 100 to 0%

    case transitionRampUpLongSharp1_100 = 88 // Transition Ramp Up Long Sharp 1 - 100 to 0%
    case transitionRampUpLongSharp2_100 = 89 // Transition Ramp Up Long Sharp 2 - 100 to 0%

    case transitionRampUpMediumSharp1_100 = 90 // Transition Ramp Up Medium Sharp 1 - 100 to 0%
    case transitionRampUpMediumSharp2_100 = 91 // Transition Ramp Up Medium Sharp 2 - 100 to 0%

    case transitionRampUpShortSharp1_100 = 92 // Transition Ramp Up Short Sharp 1 - 100 to 0%
    case transitionRampUpShortSharp2_100 = 93 // Transition Ramp Up Short Sharp 2 - 100 to 0%

    case transitionRampDownLongSmooth1_50 = 94 // Transition Ramp Down Long Smooth 1 - 50 to 0%
    case transitionRampDownLongSmooth2_50 = 95 // Transition Ramp Down Long Smooth 2 - 50 to 0%

    case transitionRampDownMediumSmooth1_50 = 96 // Transition Ramp Down Medium Smooth 1 - 50 to 0%
    case transitionRampDownMediumSmooth2_50 = 97 // Transition Ramp Down Medium Smooth 2 - 50 to 0%

    case transitionRampDownShortSmooth1_50 = 98 // Transition Ramp Down Short Smooth 1 - 50 to 0%
    case transitionRampDownShortSmooth2_50 = 99 // Transition Ramp Down Short Smooth 2 - 50 to 0%

    case transitionRampDownLongSharp1_50 = 100 // Transition Ramp Down Long Sharp 1 - 50 to 0%
    case transitionRampDownLongSharp2_50 = 101 // Transition Ramp Down Long Sharp 2 - 50 to 0%

    case transitionRampDownMediumSharp1_50 = 102 // Transition Ramp Down Medium Sharp 1 - 50 to 0%
    case transitionRampDownMediumSharp2_50 = 103 // Transition Ramp Down Medium Sharp 2 - 50 to 0%

    case transitionRampDownShortSharp1_50 = 104 // Transition Ramp Down Short Sharp 1 - 50 to 0%
    case transitionRampDownShortSharp2_50 = 105 // Transition Ramp Down Short Sharp 2 - 50 to 0%

    case transitionRampUpLongSmooth1_50 = 106 // Transition Ramp Up Long Smooth 1 - 0 to 50%
    case transitionRampUpLongSmooth2_50 = 107 // Transition Ramp Up Long Smooth 2 - 0 to 50%

    case transitionRampUpMediumSmooth1_50 = 108 // Transition Ramp Up Medium Smooth 1 - 0 to 50%
    case transitionRampUpMediumSmooth2_50 = 109 // Transition Ramp Up Medium Smooth 2 - 0 to 50%

    case transitionRampUpShortSmooth1_50 = 110 // Transition Ramp Up Short Smooth 1 - 0 to 50%
    case transitionRampUpShortSmooth2_50 = 111 // Transition Ramp Up Short Smooth 2 - 0 to 50%

    case transitionRampUpLongSharp1_50 = 112 // Transition Ramp Up Long Sharp 1 - 0 to 50%
    case transitionRampUpLongSharp2_50 = 113 // Transition Ramp Up Long Sharp 2 - 0 to 50%

    case transitionRampUpMediumSharp1_50 = 114 // Transition Ramp Up Medium Sharp 1 - 0 to 50%
    case transitionRampUpMediumSharp2_50 = 115 // Transition Ramp Up Medium Sharp 2 - 0 to 50%

    case transitionRampUpShortSharp1_50 = 116 // Transition Ramp Up Short Sharp 1 - 0 to 50%
    case transitionRampUpShortSharp2_50 = 117 // Transition Ramp Up Short Sharp 2 - 0 to 50%

    case longBuzz100 = 118 // Long buzz for programmatic stopping - 100%

    case smoothHum50 = 119 // Smooth Hum 1 (No kick or brake pulse) - 50%
    case smoothHum40 = 120 // Smooth Hum 2 (No kick or brake pulse) - 40%
    case smoothHum30 = 121 // Smooth Hum 3 (No kick or brake pulse) - 30%
    case smoothHum20 = 122 // Smooth Hum 4 (No kick or brake pulse) - 20%
    case smoothHum10 = 123 // Smooth Hum 5 (No kick or brake pulse) - 10%
}