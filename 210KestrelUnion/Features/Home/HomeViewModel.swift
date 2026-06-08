import Foundation
import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    @Published var quickText = ""
    @Published var quickDate = Date()
    @Published var quickMoodTags: Set<MoodTag> = []
    @Published var showValidationError = false
    @Published var shakeTrigger: CGFloat = 0
    @Published var showQuickSheet = false

    func toggleMood(_ mood: MoodTag) {
        if quickMoodTags.contains(mood) {
            quickMoodTags.remove(mood)
            return
        }
        if quickMoodTags.count < 2 {
            quickMoodTags.insert(mood)
        }
    }

    func validate() -> Bool {
        let valid = quickText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        showValidationError = valid == false
        if valid == false {
            shakeTrigger += 1
        }
        return valid
    }

    func reset() {
        quickText = ""
        quickDate = Date()
        quickMoodTags = []
        showValidationError = false
    }
}
