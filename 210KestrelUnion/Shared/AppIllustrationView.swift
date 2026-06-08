import SwiftUI

enum AppArt: String {
    case onboardingGratitude = "OnboardingGratitude"
    case onboardingAffirmations = "OnboardingAffirmations"
    case onboardingJourney = "OnboardingJourney"
    case homeHero = "HomeHero"
    case calmFocus = "CalmFocusArt"
    case emptyReflections = "EmptyReflections"
}

struct AppIllustrationView: View {
    let art: AppArt
    var cornerRadius: CGFloat = 16
    var contentMode: ContentMode = .fill

    var body: some View {
        Image(art.rawValue)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct WidgetAppearModifier: ViewModifier {
    let delay: Double
    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 12)
            .onAppear {
                withAnimation(.easeOut(duration: 0.35).delay(delay)) {
                    visible = true
                }
            }
    }
}

extension View {
    func widgetAppear(delay: Double = 0) -> some View {
        modifier(WidgetAppearModifier(delay: delay))
    }
}
