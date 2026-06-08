import Foundation

enum BreathingPresetType: String, Codable, CaseIterable, Identifiable {
    case fourSevenEight = "4-7-8"
    case box = "4-4-4-4"
    case fiveFive = "5-5"
    case custom = "Custom"

    var id: String { rawValue }
}

struct BreathingStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let seconds: Int
}

struct CustomBreathingPreset: Codable, Hashable {
    var inhale: Int
    var hold: Int
    var exhale: Int
    var secondHold: Int

    static let `default` = CustomBreathingPreset(inhale: 4, hold: 4, exhale: 4, secondHold: 4)
}
