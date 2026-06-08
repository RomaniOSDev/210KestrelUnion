import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStorageStore
    @EnvironmentObject private var banners: AchievementBannerCenter
    @EnvironmentObject private var tabRouter: TabRouter
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSuccess = false
    @State private var showAllReflections = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 14) {
                        heroWidget.widgetAppear(delay: 0)
                        metricsWidget.widgetAppear(delay: 0.05)
                        exploreWidget.widgetAppear(delay: 0.1)
                        promptWidget.widgetAppear(delay: 0.15)
                        quickReflectionWidget.widgetAppear(delay: 0.2)
                        recentReflectionsWidget.widgetAppear(delay: 0.25)
                    }
                    .padding(16)
                }
                SuccessCheckmarkOverlay(isVisible: $showSuccess)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Quick Add") {
                        FeedbackService.tap()
                        viewModel.showQuickSheet = true
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .sheet(isPresented: $viewModel.showQuickSheet) {
                quickAddSheet
            }
            .sheet(isPresented: $showAllReflections) {
                ReflectionView()
                    .environmentObject(store)
                    .environmentObject(banners)
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    private var heroWidget: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .bottomLeading) {
                    AppIllustrationView(art: .homeHero, cornerRadius: 14)
                        .frame(height: 150)
                        .overlay(
                            LinearGradient(
                                colors: [Color.clear, Color("AppBackground").opacity(0.75)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.title3.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Your daily wellness space")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .padding(12)
                }

                HStack(spacing: 8) {
                    streakBadge
                    if store.streakDays >= 7 {
                        Label("Strong week", systemImage: "flame.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppPrimary"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color("AppBackground"))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var streakBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
            Text("\(store.streakDays) day streak")
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color("AppAccent"))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color("AppBackground"))
        .clipShape(Capsule())
    }

    private var metricsWidget: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today at a Glance")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 10) {
                    MetricTile(title: "Reflections", value: "\(store.entriesCreated)", icon: "book.fill")
                    MetricTile(title: "Sessions", value: "\(store.totalSessionsCompleted)", icon: "wind")
                }
                HStack(spacing: 10) {
                    MetricTile(title: "Minutes", value: "\(store.totalMinutesUsed)", icon: "clock.fill")
                    MetricTile(title: "Streak", value: "\(store.streakDays)", icon: "flame.fill")
                }
            }
        }
    }

    private var exploreWidget: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Explore")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        exploreCard(
                            art: .emptyReflections,
                            title: "Reflect",
                            subtitle: "Capture thoughts",
                            action: { showAllReflections = true }
                        )
                        exploreCard(
                            art: .calmFocus,
                            title: "Breathe",
                            subtitle: "Calm focus",
                            action: { tabRouter.open(.wellness) }
                        )
                        exploreCard(
                            art: .onboardingAffirmations,
                            title: "Affirm",
                            subtitle: "Daily power",
                            action: { tabRouter.open(.wellness) }
                        )
                    }
                }
            }
        }
    }

    private func exploreCard(art: AppArt, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button {
            FeedbackService.tap()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                AppIllustrationView(art: art, cornerRadius: 12)
                    .frame(width: 140, height: 90)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .frame(width: 140, alignment: .leading)
            .padding(10)
            .background(Color("AppBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color("AppAccent").opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var promptWidget: some View {
        AppCard {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(Color("AppPrimary"))
                VStack(alignment: .leading, spacing: 5) {
                    Text("Prompt of the Day")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(store.promptOfTheDay)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
            }
        }
    }

    private var quickReflectionWidget: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("Quick Reflection", systemImage: "square.and.pencil")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Capture your thought in one tap and continue your day.")
                    .foregroundStyle(Color("AppTextSecondary"))
                Button {
                    FeedbackService.tap()
                    viewModel.showQuickSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Reflection")
                            .fontWeight(.semibold)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(Color("AppBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }

    private var recentReflectionsWidget: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Recent Reflections")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Button {
                        FeedbackService.tap()
                        showAllReflections = true
                    } label: {
                        Text("See All")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }

                if store.reflections.isEmpty {
                    HStack(spacing: 12) {
                        AppIllustrationView(art: .emptyReflections, cornerRadius: 10)
                            .frame(width: 72, height: 72)
                        Text("No reflections yet — start with your first note.")
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                } else {
                    ForEach(Array(store.reflections.prefix(3))) { reflection in
                        HStack(alignment: .top, spacing: 8) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(dateFormatter.string(from: reflection.date))
                                    .font(.caption)
                                    .foregroundStyle(Color("AppAccent"))
                                Text(reflection.text)
                                    .lineLimit(2)
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .padding(10)
                        .background(Color("AppBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    private var quickAddSheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ReflectionEntryFormView(
                    text: $viewModel.quickText,
                    date: $viewModel.quickDate,
                    selectedMoods: $viewModel.quickMoodTags,
                    showValidationError: viewModel.showValidationError,
                    shakeTrigger: viewModel.shakeTrigger,
                    promptText: store.promptOfTheDay
                )
            }
            .navigationTitle("Quick Add")
            .appSheetNavigationStyle()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        FeedbackService.tap()
                        viewModel.reset()
                        viewModel.showQuickSheet = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveQuickReflection()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }

    private func saveQuickReflection() {
        FeedbackService.mediumImpact()
        guard viewModel.validate() else {
            FeedbackService.warning()
            return
        }
        store.addReflection(
            text: viewModel.quickText,
            date: viewModel.quickDate,
            moodTags: Array(viewModel.quickMoodTags)
        )
        let newAchievements = store.evaluateAchievements()
        if newAchievements.isEmpty == false {
            FeedbackService.success()
            banners.enqueue(newAchievements)
        } else {
            FeedbackService.success()
        }
        FeedbackService.reflectionSaved()
        showSuccess = true
        viewModel.reset()
        viewModel.showQuickSheet = false
    }
}
