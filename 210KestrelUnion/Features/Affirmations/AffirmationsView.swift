import SwiftUI

struct AffirmationsView: View {
    @EnvironmentObject private var store: AppStorageStore
    @EnvironmentObject private var banners: AchievementBannerCenter
    @StateObject private var viewModel = AffirmationsViewModel()
    @State private var showSuccess = false

    var body: some View {
        let allAffirmations = viewModel.allAffirmations(custom: store.customAffirmations)
        let visibleAffirmations = viewModel.visibleAffirmations(all: allAffirmations, favorites: store.favoriteAffirmations)
        ScrollView {
            VStack(spacing: 16) {
                AppCard {
                    HStack(spacing: 12) {
                        AppIllustrationView(art: .onboardingAffirmations, cornerRadius: 12)
                            .frame(width: 72, height: 72)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Personalize Affirmations")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Choose, favorite, and repeat what empowers you.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                }
                .widgetAppear()

                affirmationCard
                sourceFilterCard
                addAffirmationCard
                favoritesQuickList(allAffirmations: allAffirmations)
                completeButton
            }
            .padding(16)
        }
        .overlay {
            SuccessCheckmarkOverlay(isVisible: $showSuccess)
        }
        .onChange(of: visibleAffirmations.count) { _, count in
            viewModel.clampSelection(count: count)
        }
    }

    private var affirmationCard: some View {
        let all = viewModel.allAffirmations(custom: store.customAffirmations)
        let visible = viewModel.visibleAffirmations(all: all, favorites: store.favoriteAffirmations)
        return AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's Statement")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                if visible.isEmpty {
                    Text("Add your first affirmation to begin.")
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    let currentText = visible.indices.contains(viewModel.selectedIndex) ? visible[viewModel.selectedIndex] : ""
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentText)
                            .font(.body)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            FeedbackService.tap()
                            _ = store.toggleFavoriteAffirmation(currentText)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: store.isFavoriteAffirmation(currentText) ? "star.fill" : "star")
                                Text(store.isFavoriteAffirmation(currentText) ? "Remove from Favorites" : "Add to Favorites")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .padding(12)
                    .background(Color("AppBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    HStack {
                        Button {
                            FeedbackService.tap()
                            viewModel.selectedIndex = max(viewModel.selectedIndex - 1, 0)
                        } label: {
                            Image(systemName: "chevron.left")
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .foregroundStyle(Color("AppPrimary"))

                        Spacer()

                        Button {
                            FeedbackService.tap()
                            viewModel.selectedIndex = min(viewModel.selectedIndex + 1, max(0, visible.count - 1))
                        } label: {
                            Image(systemName: "chevron.right")
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .foregroundStyle(Color("AppPrimary"))
                    }

                    Button {
                        FeedbackService.tap()
                        if let randomFavorite = store.randomFavoriteAffirmation(all: all), let idx = visible.firstIndex(of: randomFavorite) {
                            viewModel.selectedIndex = idx
                        } else {
                            FeedbackService.warning()
                        }
                    } label: {
                        Text("Random Favorite")
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(minHeight: 44)
                            .background(Color("AppPrimary"))
                            .foregroundStyle(Color("AppBackground"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    private var sourceFilterCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Source")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Picker("Affirmation Source", selection: $viewModel.sourceFilter) {
                    ForEach(AffirmationsViewModel.SourceFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var addAffirmationCard: some View {
        AddAffirmationFormView(
            text: $viewModel.newAffirmation,
            showError: viewModel.showError,
            shakeTrigger: viewModel.shakeTrigger
        ) {
            FeedbackService.mediumImpact()
            guard viewModel.validateNewAffirmation() else {
                FeedbackService.warning()
                return
            }
            let added = store.addCustomAffirmation(viewModel.newAffirmation)
            if added {
                viewModel.newAffirmation = ""
                viewModel.showError = false
            }
        }
    }

    private var completeButton: some View {
        Button {
            FeedbackService.mediumImpact()
            store.completeAffirmationSession(minutes: 1)
            let newAchievements = store.evaluateAchievements()
            if newAchievements.isEmpty == false {
                FeedbackService.success()
                banners.enqueue(newAchievements)
            } else {
                FeedbackService.success()
            }
            showSuccess = true
        } label: {
            Text("Complete Daily Session")
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

    private func favoritesQuickList(allAffirmations: [String]) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Favorites")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                let favorites = allAffirmations.filter { store.favoriteAffirmations.contains($0) }
                if favorites.isEmpty {
                    Text("No favorites yet.")
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(favorites.prefix(4), id: \.self) { item in
                        Button {
                            FeedbackService.tap()
                            let visible = viewModel.visibleAffirmations(all: allAffirmations, favorites: store.favoriteAffirmations)
                            if let index = visible.firstIndex(of: item) {
                                viewModel.selectedIndex = index
                                viewModel.sourceFilter = .favorites
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(Color("AppPrimary"))
                                Text(item)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                    .lineLimit(2)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
