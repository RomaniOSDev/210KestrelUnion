import SwiftUI

struct ReflectionView: View {
    @EnvironmentObject private var store: AppStorageStore
    @EnvironmentObject private var banners: AchievementBannerCenter
    @StateObject private var viewModel = ReflectionViewModel()
    @State private var showAddSheet = false
    @State private var showSuccess = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private var filteredReflections: [Reflection] {
        viewModel.filteredReflections(store.reflections)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                content
                SuccessCheckmarkOverlay(isVisible: $showSuccess)
            }
            .navigationTitle("Reflections")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Reflection") {
                        FeedbackService.tap()
                        showAddSheet = true
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .sheet(isPresented: $showAddSheet) {
                addReflectionSheet
            }
            .searchable(text: $viewModel.searchText, prompt: "Search reflections")
        }
    }

    @ViewBuilder
    private var content: some View {
        if store.reflections.isEmpty {
            ScrollView {
                VStack(spacing: 18) {
                    AppIllustrationView(art: .emptyReflections, cornerRadius: 20)
                        .frame(width: 180, height: 180)
                    Text("Start your reflection journey!")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("No reflections yet — tap ‘Add Reflection’ to begin!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Button {
                        FeedbackService.tap()
                        showAddSheet = true
                    } label: {
                        Text("Add Reflection")
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(minHeight: 44)
                            .background(Color("AppPrimary"))
                            .foregroundStyle(Color("AppBackground"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    promptCard
                }
                .padding(24)
                .frame(maxWidth: .infinity, minHeight: 360)
            }
        } else {
            VStack(spacing: 10) {
                summaryTiles
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                promptCard
                    .padding(.horizontal, 16)
                filtersCard
                    .padding(.horizontal, 16)
                List {
                    if filteredReflections.isEmpty {
                        Text("No reflections match your filters.")
                            .foregroundStyle(Color("AppTextSecondary"))
                            .listRowBackground(Color("AppSurface"))
                    } else {
                        ForEach(filteredReflections) { reflection in
                            ReflectionRowCell(reflection: reflection, dateFormatter: dateFormatter)
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteReflection(reflection.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowBackground(Color("AppSurface"))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
        }
    }

    private var addReflectionSheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ReflectionEntryFormView(
                    text: $viewModel.inputText,
                    date: $viewModel.selectedDate,
                    selectedMoods: $viewModel.selectedMoodTagsForNewEntry,
                    showValidationError: viewModel.showValidationError,
                    shakeTrigger: viewModel.shakeTrigger,
                    promptText: store.promptOfTheDay
                )
            }
            .navigationTitle("Add Reflection")
            .appSheetNavigationStyle()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        FeedbackService.tap()
                        viewModel.reset()
                        showAddSheet = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveReflection()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }

    private func deleteReflection(_ id: UUID) {
        FeedbackService.tap()
        guard let index = store.reflections.firstIndex(where: { $0.id == id }) else { return }
        store.deleteReflections(at: IndexSet(integer: index))
        banners.enqueue(store.evaluateAchievements())
    }

    private func saveReflection() {
        FeedbackService.mediumImpact()
        guard viewModel.validate() else {
            FeedbackService.warning()
            return
        }
        store.addReflection(
            text: viewModel.inputText,
            date: viewModel.selectedDate,
            moodTags: Array(viewModel.selectedMoodTagsForNewEntry)
        )
        let newAchievements = store.evaluateAchievements()
        if newAchievements.isEmpty == false {
            FeedbackService.success()
            banners.enqueue(newAchievements)
        }
        FeedbackService.reflectionSaved()
        showSuccess = true
        viewModel.reset()
        showAddSheet = false
    }

    private var promptCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Color("AppPrimary"))
                    Text("Prompt of the Day")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                Text(store.promptOfTheDay)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }

    private var filtersCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Filters")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))

                Picker("Date", selection: $viewModel.selectedDateFilter) {
                    ForEach(ReflectionViewModel.DateFilter.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MoodTag.allCases) { tag in
                            Button {
                                FeedbackService.tap()
                                viewModel.toggleMoodFilterTag(tag)
                            } label: {
                                moodChip(tag: tag, selected: viewModel.selectedMoodFilterTags.contains(tag))
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
    
    private var summaryTiles: some View {
        HStack(spacing: 10) {
            MetricTile(title: "All Entries", value: "\(store.reflections.count)", icon: "book.fill")
            MetricTile(title: "Filtered", value: "\(filteredReflections.count)", icon: "line.3.horizontal.decrease.circle.fill")
            MetricTile(title: "Tagged", value: "\(store.reflections.filter { $0.moodTags.isEmpty == false }.count)", icon: "tag.fill")
        }
    }

    private func moodChip(tag: MoodTag, selected: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: tag.symbol)
            Text(tag.rawValue)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(selected ? Color("AppPrimary") : Color("AppBackground"))
        .foregroundStyle(selected ? Color("AppBackground") : Color("AppTextSecondary"))
        .clipShape(Capsule())
    }
}

private struct ReflectionRowCell: View {
    let reflection: Reflection
    let dateFormatter: DateFormatter

    var body: some View {
        AppCard(elevated: false) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(dateFormatter.string(from: reflection.date), systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppAccent"))
                    Spacer()
                    Image(systemName: "quote.opening")
                        .foregroundStyle(Color("AppPrimary").opacity(0.5))
                }
                Text(reflection.text)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(3)
                if reflection.moodTags.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(reflection.moodTags) { tag in
                                HStack(spacing: 4) {
                                    Image(systemName: tag.symbol)
                                    Text(tag.rawValue)
                                }
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color("AppPrimary"))
                                .foregroundStyle(Color("AppBackground"))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }
}
