import SwiftUI
import AudioToolbox

struct EmotionalProgressView: View {
    @EnvironmentObject private var store: AppStorageStore
    @StateObject private var viewModel = EmotionalProgressViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                weeklyReportCard
                moodSliceCard
                weeklyChartCard
                heatmapCard
                selectedDetailsCard

                NavigationLink {
                    EmotionalProgressDetailsView()
                        .environmentObject(store)
                } label: {
                    Text("View Details")
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("AppPrimary"))
                        .foregroundStyle(Color("AppBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(16)
        }
        .background(AppBackgroundView())
    }

    private var weeklyReportCard: some View {
        let insight = store.weeklyInsight()
        return AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("This Week")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                reportRow("Entries logged", "\(insight.entriesThisWeek)")
                reportRow("Most active day", insight.mostActiveDay)
                reportRow("Streak note", insight.streakDeltaText)
            }
        }
    }

    private var moodSliceCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Mood Slice (7 Days)")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                let distribution = store.moodDistributionForLastWeek()
                if distribution.allSatisfy({ $0.1 == 0 }) {
                    Text("Add mood tags in reflections to see qualitative trends.")
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(distribution, id: \.0.id) { tag, count in
                        HStack {
                            Label(tag.rawValue, systemImage: tag.symbol)
                                .foregroundStyle(Color("AppTextSecondary"))
                            Spacer()
                            Text("\(count)")
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Streak: \(store.streakCounter) days")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                if store.reflections.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "leaf.arrow.circlepath")
                            .foregroundStyle(Color("AppAccent"))
                        Text("Track your journey to self-discovery")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                } else {
                    Text("Tap a bar or a heatmap cell for details.")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }

    private var weeklyChartCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Weekly Summary")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))

                Canvas { context, size in
                    let values = shiftedWeek()
                    let maxValue = max(values.max() ?? 1, 1)
                    let width = size.width / CGFloat(max(values.count, 1))
                    for (index, value) in values.enumerated() {
                        let heightRatio = CGFloat(value) / CGFloat(maxValue)
                        let barHeight = max(8, size.height * heightRatio)
                        let x = CGFloat(index) * width + width * 0.15
                        let y = size.height - barHeight
                        let rect = CGRect(x: x, y: y, width: width * 0.7, height: barHeight)
                        let color = viewModel.selectedWeeklyIndex == index ? Color("AppPrimary") : Color("AppAccent")
                        context.fill(Path(roundedRect: rect, cornerRadius: 5), with: .color(color))
                    }
                }
                .frame(height: 130)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 16)
                        .onEnded { value in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.shiftWeek(left: value.translation.width < 0)
                            }
                        }
                )
                .overlay {
                    GeometryReader { proxy in
                        HStack(spacing: 0) {
                            ForEach(0..<7, id: \.self) { index in
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        FeedbackService.tap()
                                        viewModel.selectedWeeklyIndex = index
                                    }
                                    .frame(width: proxy.size.width / 7)
                            }
                        }
                    }
                }
            }
        }
    }

    private var heatmapCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Monthly Heatmap")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                VStack(spacing: 5) {
                    ForEach(Array(shiftedHeatmap().enumerated()), id: \.offset) { row, values in
                        HStack(spacing: 5) {
                            ForEach(Array(values.enumerated()), id: \.offset) { col, value in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(heatColor(value: value))
                                    .frame(maxWidth: .infinity, minHeight: 20)
                                    .onTapGesture {
                                        FeedbackService.tap()
                                        viewModel.selectedHeatmapCell = (row, col)
                                    }
                            }
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 16)
                        .onEnded { value in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.shiftMonth(left: value.translation.width < 0)
                            }
                        }
                )
            }
        }
    }

    private var selectedDetailsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 6) {
                if let index = viewModel.selectedWeeklyIndex {
                    Text("Selected day: \(index + 1), entries: \(shiftedWeek()[safe: index] ?? 0)")
                        .foregroundStyle(Color("AppTextPrimary"))
                } else if let cell = viewModel.selectedHeatmapCell {
                    let value = shiftedHeatmap()[safe: cell.row]?[safe: cell.col] ?? 0
                    Text("Selected heatmap cell: \(value) entries")
                        .foregroundStyle(Color("AppTextPrimary"))
                } else {
                    Text("Select a chart element to inspect details.")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }

    private func shiftedWeek() -> [Int] {
        let data = store.weeklySummaryData
        guard data.isEmpty == false else { return Array(repeating: 0, count: 7) }
        let count = data.count
        let shift = ((viewModel.weekShift % count) + count) % count
        let head = Array(data[shift...])
        let tail = Array(data[..<shift])
        return head + tail
    }

    private func shiftedHeatmap() -> [[Int]] {
        let rows = store.calendarHeatmapData
        guard rows.isEmpty == false else { return Array(repeating: Array(repeating: 0, count: 7), count: 6) }
        let count = rows.count
        let shift = ((viewModel.monthShift % count) + count) % count
        let head = Array(rows[shift...])
        let tail = Array(rows[..<shift])
        return head + tail
    }

    private func heatColor(value: Int) -> Color {
        switch value {
        case 0: return Color("AppBackground")
        case 1: return Color("AppAccent").opacity(0.4)
        case 2: return Color("AppAccent").opacity(0.6)
        default: return Color("AppPrimary")
        }
    }

    private func reportRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
            Text(value)
                .foregroundStyle(Color("AppTextPrimary"))
                .fontWeight(.semibold)
        }
    }
}

struct EmotionalProgressDetailsView: View {
    @EnvironmentObject private var store: AppStorageStore
    @EnvironmentObject private var banners: AchievementBannerCenter
    @State private var animateIn = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                statsRow(title: "Current Streak", value: "\(store.streakDays) days")
                statsRow(title: "Longest Streak", value: "\(store.longestStreak) days")
                statsRow(title: "Total Reflections", value: "\(store.entriesCreated)")
                statsRow(title: "Practice Minutes", value: "\(store.totalMinutesPracticed)")
            }
            .padding(16)
            .opacity(animateIn ? 1 : 0.3)
            .onAppear {
                FeedbackService.softImpact()
                AudioServicesPlaySystemSound(1057)
                store.didOpenInsights()
                let newAchievements = store.evaluateAchievements()
                if newAchievements.isEmpty == false {
                    FeedbackService.success()
                    banners.enqueue(newAchievements)
                }
                withAnimation(.easeInOut(duration: 0.3)) {
                    animateIn = true
                }
            }
        }
        .background(AppBackgroundView())
        .navigationTitle("Insight Details")
    }

    private func statsRow(title: String, value: String) -> some View {
        AppCard {
            HStack {
                Text(title)
                    .foregroundStyle(Color("AppTextSecondary"))
                Spacer()
                Text(value)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .fontWeight(.semibold)
            }
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
