import Foundation
import SwiftUI
import Combine

final class AffirmationsViewModel: ObservableObject {
    enum SourceFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case favorites = "Favorites"

        var id: String { rawValue }
    }

    @Published var selectedIndex: Int = 0
    @Published var newAffirmation = ""
    @Published var showError = false
    @Published var shakeTrigger: CGFloat = 0
    @Published var sourceFilter: SourceFilter = .all

    let defaultAffirmations = [
        "I am capable of growing through each day.",
        "I choose calm thoughts and steady progress.",
        "My reflections help me understand myself better.",
        "I have the strength to handle what comes today."
    ]

    func allAffirmations(custom: [String]) -> [String] {
        defaultAffirmations + custom
    }

    func visibleAffirmations(all: [String], favorites: [String]) -> [String] {
        switch sourceFilter {
        case .all:
            return all
        case .favorites:
            return all.filter { favorites.contains($0) }
        }
    }

    func validateNewAffirmation() -> Bool {
        let valid = newAffirmation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        showError = valid == false
        if valid == false {
            shakeTrigger += 1
        }
        return valid
    }

    func clampSelection(count: Int) {
        if count == 0 {
            selectedIndex = 0
        } else {
            selectedIndex = min(selectedIndex, count - 1)
        }
    }
}
