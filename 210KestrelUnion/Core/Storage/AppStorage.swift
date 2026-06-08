import Foundation
import Combine

final class AppStorageStore: ObservableObject {
    @Published var hasSeenOnboarding: Bool { didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding); defaults.set(hasSeenOnboarding, forKey: Keys.hasOnboarded) } }
    @Published var totalSessionsCompleted: Int { didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) } }
    @Published var totalMinutesUsed: Int { didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) } }
    @Published var streakDays: Int { didSet { defaults.set(streakDays, forKey: Keys.streakDays) } }
    @Published var longestStreak: Int { didSet { defaults.set(longestStreak, forKey: Keys.longestStreak) } }
    @Published var lastActivityDate: Date? { didSet { defaults.set(lastActivityDate, forKey: Keys.lastActivityDate) } }
    @Published var achievementsUnlocked: [String: Date] { didSet { saveCodable(achievementsUnlocked, key: Keys.achievementsUnlocked) } }

    @Published var reflections: [Reflection] { didSet { saveCodable(reflections, key: Keys.reflections) } }
    @Published var lastUsedDate: String { didSet { defaults.set(lastUsedDate, forKey: Keys.lastUsedDate) } }
    @Published var hasOnboarded: Bool { didSet { defaults.set(hasOnboarded, forKey: Keys.hasOnboarded) } }

    @Published var breathSessionsCompleted: Int { didSet { defaults.set(breathSessionsCompleted, forKey: Keys.breathSessionsCompleted) } }
    @Published var lastSessionDate: Date? { didSet { defaults.set(lastSessionDate, forKey: Keys.lastSessionDate) } }

    @Published var streakCounter: Int { didSet { defaults.set(streakCounter, forKey: Keys.streakCounter) } }
    @Published var weeklySummaryData: [Int] { didSet { saveCodable(weeklySummaryData, key: Keys.weeklySummaryData) } }
    @Published var calendarHeatmapData: [[Int]] { didSet { saveCodable(calendarHeatmapData, key: Keys.calendarHeatmapData) } }
    @Published var firstLaunchDate: Date { didSet { defaults.set(firstLaunchDate, forKey: Keys.firstLaunchDate) } }

    @Published var sessionsCompleted: Int { didSet { defaults.set(sessionsCompleted, forKey: Keys.sessionsCompleted) } }
    @Published var totalMinutesPracticed: Int { didSet { defaults.set(totalMinutesPracticed, forKey: Keys.totalMinutesPracticed) } }
    @Published var customAffirmations: [String] { didSet { saveCodable(customAffirmations, key: Keys.customAffirmations) } }
    @Published var favoriteAffirmations: [String] { didSet { saveCodable(favoriteAffirmations, key: Keys.favoriteAffirmations) } }
    @Published var selectedBreathingPreset: BreathingPresetType { didSet { defaults.set(selectedBreathingPreset.rawValue, forKey: Keys.selectedBreathingPreset) } }
    @Published var customBreathingPreset: CustomBreathingPreset { didSet { saveCodable(customBreathingPreset, key: Keys.customBreathingPreset) } }

    private let defaults: UserDefaults
    private let calendar = Calendar.current

    var entriesCreated: Int { reflections.count }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding) || defaults.bool(forKey: Keys.hasOnboarded)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = AppStorageStore.readCodable([String: Date].self, key: Keys.achievementsUnlocked, defaults: defaults) ?? [:]

        reflections = AppStorageStore.readCodable([Reflection].self, key: Keys.reflections, defaults: defaults) ?? []
        lastUsedDate = defaults.string(forKey: Keys.lastUsedDate) ?? ""
        hasOnboarded = defaults.bool(forKey: Keys.hasOnboarded)

        breathSessionsCompleted = defaults.integer(forKey: Keys.breathSessionsCompleted)
        lastSessionDate = defaults.object(forKey: Keys.lastSessionDate) as? Date

        streakCounter = defaults.integer(forKey: Keys.streakCounter)
        weeklySummaryData = AppStorageStore.readCodable([Int].self, key: Keys.weeklySummaryData, defaults: defaults) ?? Array(repeating: 0, count: 7)
        calendarHeatmapData = AppStorageStore.readCodable([[Int]].self, key: Keys.calendarHeatmapData, defaults: defaults) ?? Array(repeating: Array(repeating: 0, count: 7), count: 6)
        firstLaunchDate = defaults.object(forKey: Keys.firstLaunchDate) as? Date ?? Date()

        sessionsCompleted = defaults.integer(forKey: Keys.sessionsCompleted)
        totalMinutesPracticed = defaults.integer(forKey: Keys.totalMinutesPracticed)
        customAffirmations = AppStorageStore.readCodable([String].self, key: Keys.customAffirmations, defaults: defaults) ?? []
        favoriteAffirmations = AppStorageStore.readCodable([String].self, key: Keys.favoriteAffirmations, defaults: defaults) ?? []
        if let presetRawValue = defaults.string(forKey: Keys.selectedBreathingPreset), let preset = BreathingPresetType(rawValue: presetRawValue) {
            selectedBreathingPreset = preset
        } else {
            selectedBreathingPreset = .fourSevenEight
        }
        customBreathingPreset = AppStorageStore.readCodable(CustomBreathingPreset.self, key: Keys.customBreathingPreset, defaults: defaults) ?? .default

        recalculateDerivedData()
    }

    func markOnboardingComplete() {
        hasSeenOnboarding = true
        hasOnboarded = true
    }

    func addReflection(text: String, date: Date, moodTags: [MoodTag] = []) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        reflections.append(Reflection(date: date, text: trimmed, moodTags: Array(moodTags.prefix(2))))
        reflections.sort { $0.date > $1.date }
        lastUsedDate = ISO8601DateFormatter().string(from: Date())
        registerMeaningfulActivity(on: date)
        recalculateDerivedData()
    }

    func deleteReflections(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            guard reflections.indices.contains(index) else { continue }
            reflections.remove(at: index)
        }
        recalculateDerivedData()
    }

    func completeBreathingSession(minutes: Int) {
        let safeMinutes = max(minutes, 0)
        breathSessionsCompleted += 1
        totalSessionsCompleted += 1
        totalMinutesUsed += safeMinutes
        totalMinutesPracticed += safeMinutes
        lastSessionDate = Date()
        registerMeaningfulActivity(on: Date())
    }

    func completeAffirmationSession(minutes: Int) {
        let safeMinutes = max(minutes, 0)
        sessionsCompleted += 1
        totalSessionsCompleted += 1
        totalMinutesUsed += safeMinutes
        totalMinutesPracticed += safeMinutes
        registerMeaningfulActivity(on: Date())
    }

    func addCustomAffirmation(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return false }
        customAffirmations.append(trimmed)
        return true
    }

    func toggleFavoriteAffirmation(_ text: String) -> Bool {
        if let index = favoriteAffirmations.firstIndex(of: text) {
            favoriteAffirmations.remove(at: index)
            return false
        }
        favoriteAffirmations.append(text)
        return true
    }

    func isFavoriteAffirmation(_ text: String) -> Bool {
        favoriteAffirmations.contains(text)
    }

    func randomFavoriteAffirmation(all: [String]) -> String? {
        let favorites = all.filter { favoriteAffirmations.contains($0) }
        return favorites.randomElement()
    }

    func removeCustomAffirmations(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            guard customAffirmations.indices.contains(index) else { continue }
            customAffirmations.remove(at: index)
        }
    }

    func didOpenInsights() {
        sessionsCompleted += 1
        registerMeaningfulActivity(on: Date())
    }

    func resetAllData() {
        Keys.all.forEach { defaults.removeObject(forKey: $0) }
        hasSeenOnboarding = false
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        longestStreak = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]

        reflections = []
        lastUsedDate = ""
        hasOnboarded = false

        breathSessionsCompleted = 0
        lastSessionDate = nil
        streakCounter = 0
        weeklySummaryData = Array(repeating: 0, count: 7)
        calendarHeatmapData = Array(repeating: Array(repeating: 0, count: 7), count: 6)
        firstLaunchDate = Date()

        sessionsCompleted = 0
        totalMinutesPracticed = 0
        customAffirmations = []
        favoriteAffirmations = []
        selectedBreathingPreset = .fourSevenEight
        customBreathingPreset = .default
    }

    var promptOfTheDay: String {
        let prompts = [
            "What small moment made you feel grounded today?",
            "Which action today reflected your values?",
            "What challenged you, and how did you respond?",
            "Which thought helped you stay calm today?",
            "What are you grateful for right now?",
            "What gave you energy today?",
            "How did you show kindness to yourself today?"
        ]
        let dayNumber = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayNumber % prompts.count
        return prompts[index]
    }

    func breathingSteps(for preset: BreathingPresetType? = nil) -> [BreathingStep] {
        let resolved = preset ?? selectedBreathingPreset
        switch resolved {
        case .fourSevenEight:
            return [
                BreathingStep(title: "Inhale", seconds: 4),
                BreathingStep(title: "Hold", seconds: 7),
                BreathingStep(title: "Exhale", seconds: 8)
            ]
        case .box:
            return [
                BreathingStep(title: "Inhale", seconds: 4),
                BreathingStep(title: "Hold", seconds: 4),
                BreathingStep(title: "Exhale", seconds: 4),
                BreathingStep(title: "Hold", seconds: 4)
            ]
        case .fiveFive:
            return [
                BreathingStep(title: "Inhale", seconds: 5),
                BreathingStep(title: "Exhale", seconds: 5)
            ]
        case .custom:
            let custom = customBreathingPreset
            var steps: [BreathingStep] = [
                BreathingStep(title: "Inhale", seconds: max(1, custom.inhale)),
                BreathingStep(title: "Hold", seconds: max(1, custom.hold)),
                BreathingStep(title: "Exhale", seconds: max(1, custom.exhale))
            ]
            if custom.secondHold > 0 {
                steps.append(BreathingStep(title: "Hold", seconds: max(1, custom.secondHold)))
            }
            return steps
        }
    }

    func weeklyInsight() -> WeeklyInsight {
        let entries = weeklySummaryData
        let total = entries.reduce(0, +)
        let dayNames = calendar.shortWeekdaySymbols
        let maxValue = entries.max() ?? 0
        let dayIndex = entries.firstIndex(of: maxValue) ?? 0
        let safeDay = dayNames.indices.contains(dayIndex) ? dayNames[dayIndex] : "N/A"
        let streakDeltaText: String
        if streakDays >= 7 {
            streakDeltaText = "Streak is strong this week."
        } else if streakDays > 0 {
            streakDeltaText = "Keep going to build your streak."
        } else {
            streakDeltaText = "Start today to build momentum."
        }
        return WeeklyInsight(entriesThisWeek: total, mostActiveDay: safeDay, streakDeltaText: streakDeltaText)
    }

    func moodDistributionForLastWeek() -> [(MoodTag, Int)] {
        let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date())) ?? Date()
        var counts: [MoodTag: Int] = [:]
        for reflection in reflections where reflection.date >= startDate {
            for tag in reflection.moodTags {
                counts[tag, default: 0] += 1
            }
        }
        return MoodTag.allCases.map { ($0, counts[$0, default: 0]) }
    }

    func allAchievements() -> [Achievement] {
        let definitions: [(String, String, String, String, Bool)] = [
            ("first_entry", "First Entry", "Created your first journal entry.", "pencil.and.outline", entriesCreated >= 1),
            ("daily_dedication", "Daily Dedication", "Logged entries for seven consecutive days.", "flame.fill", streakDays >= 7),
            ("consistent_recorder", "Consistent Recorder", "Recorded thirty entries in total.", "calendar.badge.plus", entriesCreated >= 30),
            ("affirmation_advocate", "Affirmation Advocate", "Used daily affirmations for ten sessions.", "quote.bubble.fill", sessionsCompleted >= 10),
            ("grateful_100", "#Grateful100", "Logged one hundred gratitude entries.", "sparkles.rectangle.stack.fill", entriesCreated >= 100),
            ("half_hour_mark", "Half Hour Mark", "Practiced affirmations for over thirty minutes cumulatively.", "clock.fill", totalMinutesPracticed >= 30),
            ("month_mindful", "Month Mindful", "Maintained a logging streak for thirty days.", "leaf.fill", longestStreak >= 30),
            ("insightful_observer", "Insightful Observer", "Reviewed emotional growth insights five times.", "chart.bar.xaxis", sessionsCompleted >= 5)
        ]

        return definitions.map { id, title, details, symbol, unlocked in
            Achievement(
                id: id,
                title: title,
                details: details,
                symbol: symbol,
                isUnlocked: unlocked,
                unlockedAt: achievementsUnlocked[id]
            )
        }
    }

    @discardableResult
    func evaluateAchievements() -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        for achievement in allAchievements() where achievement.isUnlocked {
            if achievementsUnlocked[achievement.id] == nil {
                achievementsUnlocked[achievement.id] = Date()
                newlyUnlocked.append(achievement)
            }
        }
        return newlyUnlocked
    }

    private func registerMeaningfulActivity(on date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)
        if let last = lastActivityDate {
            let lastNormalized = calendar.startOfDay(for: last)
            if normalizedDate == lastNormalized {
                return
            }
            let components = calendar.dateComponents([.day], from: lastNormalized, to: normalizedDate)
            if components.day == 1 {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        longestStreak = max(longestStreak, streakDays)
        lastActivityDate = normalizedDate
        streakCounter = streakDays
    }

    private func recalculateDerivedData() {
        recalculateWeeklySummary()
        recalculateHeatmap()
        streakCounter = streakDays
    }

    private func recalculateWeeklySummary() {
        var values = Array(repeating: 0, count: 7)
        let today = calendar.startOfDay(for: Date())
        for reflection in reflections {
            let day = calendar.startOfDay(for: reflection.date)
            guard let dayOffset = calendar.dateComponents([.day], from: day, to: today).day else { continue }
            guard dayOffset >= 0, dayOffset <= 6 else { continue }
            values[6 - dayOffset] += 1
        }
        weeklySummaryData = values
    }

    private func recalculateHeatmap() {
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -41, to: today) else { return }
        var map = Array(repeating: Array(repeating: 0, count: 7), count: 6)
        for reflection in reflections {
            let day = calendar.startOfDay(for: reflection.date)
            guard let diff = calendar.dateComponents([.day], from: startDate, to: day).day else { continue }
            guard diff >= 0, diff < 42 else { continue }
            let row = diff / 7
            let col = diff % 7
            map[row][col] += 1
        }
        calendarHeatmapData = map
    }

    private func saveCodable<T: Codable>(_ value: T, key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func readCodable<T: Codable>(_ type: T.Type, key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

private enum Keys {
    static let hasSeenOnboarding = "hasSeenOnboarding"
    static let totalSessionsCompleted = "totalSessionsCompleted"
    static let totalMinutesUsed = "totalMinutesUsed"
    static let streakDays = "streakDays"
    static let longestStreak = "longestStreak"
    static let lastActivityDate = "lastActivityDate"
    static let achievementsUnlocked = "achievementsUnlocked"
    static let reflections = "reflections"
    static let lastUsedDate = "lastUsedDate"
    static let hasOnboarded = "hasOnboarded"
    static let breathSessionsCompleted = "breathSessionsCompleted"
    static let lastSessionDate = "lastSessionDate"
    static let streakCounter = "streakCounter"
    static let weeklySummaryData = "weeklySummaryData"
    static let calendarHeatmapData = "calendarHeatmapData"
    static let firstLaunchDate = "firstLaunchDate"
    static let sessionsCompleted = "sessionsCompleted"
    static let totalMinutesPracticed = "totalMinutesPracticed"
    static let customAffirmations = "customAffirmations"
    static let favoriteAffirmations = "favoriteAffirmations"
    static let selectedBreathingPreset = "selectedBreathingPreset"
    static let customBreathingPreset = "customBreathingPreset"

    static let all: [String] = [
        hasSeenOnboarding,
        totalSessionsCompleted,
        totalMinutesUsed,
        streakDays,
        longestStreak,
        lastActivityDate,
        achievementsUnlocked,
        reflections,
        lastUsedDate,
        hasOnboarded,
        breathSessionsCompleted,
        lastSessionDate,
        streakCounter,
        weeklySummaryData,
        calendarHeatmapData,
        firstLaunchDate,
        sessionsCompleted,
        totalMinutesPracticed,
        customAffirmations,
        favoriteAffirmations,
        selectedBreathingPreset,
        customBreathingPreset
    ]
}
