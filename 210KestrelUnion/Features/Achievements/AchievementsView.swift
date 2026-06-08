import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppStorageStore
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    summaryCard
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.allAchievements()) { achievement in
                            achievementCell(achievement)
                        }
                    }
                }
                .padding(16)
            }
            .background(AppBackgroundView())
            .navigationTitle("Stats & Achievements")
        }
    }

    private var summaryCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Summary")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 10) {
                    MetricTile(title: "Reflections", value: "\(store.entriesCreated)", icon: "book.fill")
                    MetricTile(title: "Minutes", value: "\(store.totalMinutesPracticed)", icon: "clock.fill")
                }
                HStack(spacing: 10) {
                    MetricTile(title: "Streak", value: "\(store.streakDays) days", icon: "flame.fill")
                    MetricTile(title: "Unlocked", value: "\(store.allAchievements().filter(\.isUnlocked).count)/8", icon: "rosette")
                }
            }
        }
    }

    private func achievementCell(_ achievement: Achievement) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: achievement.symbol)
                        .foregroundStyle(achievement.isUnlocked ? Color("AppPrimary") : Color("AppTextSecondary"))
                    Spacer()
                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(achievement.details)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(3)
                if let unlockedAt = achievement.unlockedAt {
                    Text("Unlocked \(unlockedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundStyle(Color("AppAccent"))
                } else {
                    Text("In progress")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .opacity(achievement.isUnlocked ? 1 : 0.8)
    }
}
