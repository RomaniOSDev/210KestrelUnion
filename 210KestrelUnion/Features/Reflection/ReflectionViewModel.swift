import Foundation
import SwiftUI
import Combine

final class ReflectionViewModel: ObservableObject {
    enum DateFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case today = "Today"
        case last7Days = "Last 7 Days"
        case thisMonth = "This Month"

        var id: String { rawValue }
    }

    @Published var inputText = ""
    @Published var selectedDate = Date()
    @Published var showValidationError = false
    @Published var shakeTrigger: CGFloat = 0
    @Published var selectedMoodTagsForNewEntry: Set<MoodTag> = []
    @Published var searchText = ""
    @Published var selectedDateFilter: DateFilter = .all
    @Published var selectedMoodFilterTags: Set<MoodTag> = []

    func reset() {
        inputText = ""
        selectedDate = Date()
        showValidationError = false
        selectedMoodTagsForNewEntry = []
    }

    func validate() -> Bool {
        let isValid = inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        showValidationError = isValid == false
        if isValid == false {
            shakeTrigger += 1
        }
        return isValid
    }

    func toggleNewEntryMoodTag(_ tag: MoodTag) {
        if selectedMoodTagsForNewEntry.contains(tag) {
            selectedMoodTagsForNewEntry.remove(tag)
            return
        }
        if selectedMoodTagsForNewEntry.count < 2 {
            selectedMoodTagsForNewEntry.insert(tag)
        }
    }

    func toggleMoodFilterTag(_ tag: MoodTag) {
        if selectedMoodFilterTags.contains(tag) {
            selectedMoodFilterTags.remove(tag)
        } else {
            selectedMoodFilterTags.insert(tag)
        }
    }

    func filteredReflections(_ reflections: [Reflection]) -> [Reflection] {
        let calendar = Calendar.current
        let now = Date()

        return reflections.filter { reflection in
            let matchesSearch: Bool = {
                guard searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else { return true }
                return reflection.text.localizedCaseInsensitiveContains(searchText)
            }()

            let matchesDate: Bool = {
                switch selectedDateFilter {
                case .all:
                    return true
                case .today:
                    return calendar.isDateInToday(reflection.date)
                case .last7Days:
                    guard let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return true }
                    return reflection.date >= start
                case .thisMonth:
                    let c1 = calendar.dateComponents([.year, .month], from: reflection.date)
                    let c2 = calendar.dateComponents([.year, .month], from: now)
                    return c1.year == c2.year && c1.month == c2.month
                }
            }()

            let matchesMood: Bool = {
                guard selectedMoodFilterTags.isEmpty == false else { return true }
                return selectedMoodFilterTags.allSatisfy { reflection.moodTags.contains($0) }
            }()

            return matchesSearch && matchesDate && matchesMood
        }
    }
}
