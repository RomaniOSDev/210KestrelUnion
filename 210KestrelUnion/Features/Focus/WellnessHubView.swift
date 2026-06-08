import SwiftUI

struct WellnessHubView: View {
    enum Section: String, CaseIterable, Identifiable {
        case calmFocus = "Calm Focus"
        case affirmations = "Affirmations"
        case progress = "Progress"
        var id: String { rawValue }
    }

    @State private var selected: Section = .calmFocus

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 12) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Section.allCases) { section in
                                Button {
                                    FeedbackService.tap()
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selected = section
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: icon(for: section))
                                        Text(section.rawValue)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(minHeight: 44)
                                    .background(selected == section ? Color("AppPrimary") : Color("AppSurface"))
                                    .foregroundStyle(selected == section ? Color("AppBackground") : Color("AppTextSecondary"))
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(PressScaleButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    Group {
                        switch selected {
                        case .calmFocus:
                            CalmFocusView()
                        case .affirmations:
                            AffirmationsView()
                        case .progress:
                            EmotionalProgressView()
                        }
                    }
                }
            }
            .navigationTitle(selected.rawValue)
        }
    }

    private func icon(for section: Section) -> String {
        switch section {
        case .calmFocus: return "wind"
        case .affirmations: return "text.quote"
        case .progress: return "chart.bar.fill"
        }
    }
}
