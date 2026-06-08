import SwiftUI

struct OnboardingView: View {
    struct Page: Identifiable {
        let id = UUID()
        let headline: String
        let description: String
        let art: AppArt
    }

    let onDone: () -> Void
    @State private var pageIndex = 0
    @State private var animateIllustration = false

    private var pages: [Page] {
        [
            Page(
                headline: "Foster Gratitude",
                description: "Record daily moments of gratitude to enhance positivity.",
                art: .onboardingGratitude
            ),
            Page(
                headline: "Personalize Affirmations",
                description: "Select or create personal affirmations for daily empowerment.",
                art: .onboardingAffirmations
            ),
            Page(
                headline: "Start Your Journey",
                description: "Begin by logging your first gratitude entry today.",
                art: .onboardingJourney
            )
        ]
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 16) {
                progressStrip
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingCard(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: pageIndex)

                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { idx in
                        Capsule()
                            .fill(idx == pageIndex ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.35))
                            .frame(width: idx == pageIndex ? 22 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.25), value: pageIndex)
                    }
                }

                Button {
                    FeedbackService.tap()
                    if pageIndex < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            pageIndex += 1
                            animateIllustration = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            animateIllustration = true
                        }
                    } else {
                        FeedbackService.mediumImpact()
                        onDone()
                    }
                } label: {
                    Text(pageIndex == pages.count - 1 ? "Get Started" : "Next")
                        .fontWeight(.semibold)
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
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .onAppear {
            animateIllustration = true
        }
    }

    private var progressStrip: some View {
        AppCard(elevated: false) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Step \(pageIndex + 1) of \(pages.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("AppBackground"))
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * CGFloat(pageIndex + 1) / CGFloat(pages.count))
                            .animation(.easeInOut(duration: 0.3), value: pageIndex)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    private func onboardingCard(page: Page) -> some View {
        AppCard {
            VStack(spacing: 16) {
                AppIllustrationView(art: page.art, cornerRadius: 18)
                    .frame(height: 240)
                    .scaleEffect(animateIllustration ? 1 : 0.92)
                    .opacity(animateIllustration ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.72), value: animateIllustration)

                Text(page.headline)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.horizontal, 6)
            }
            .padding(.vertical, 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
