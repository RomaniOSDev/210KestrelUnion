import Foundation
import SwiftUI
import Combine

final class AchievementBannerCenter: ObservableObject {
    @Published private(set) var current: Achievement?
    @Published private(set) var isVisible = false

    private var queue: [Achievement] = []
    private var isPresenting = false

    func enqueue(_ achievements: [Achievement]) {
        guard achievements.isEmpty == false else { return }
        queue.append(contentsOf: achievements)
        showNextIfPossible()
    }

    private func showNextIfPossible() {
        guard isPresenting == false, let next = queue.first else { return }
        queue.removeFirst()
        isPresenting = true
        current = next

        withAnimation(.easeInOut(duration: 0.3)) {
            isVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.current = nil
                self.isPresenting = false
                self.showNextIfPossible()
            }
        }
    }
}

struct AchievementBannerView: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "star.circle.fill")
                .foregroundStyle(Color("AppPrimary"))
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            Spacer()
        }
        .padding(12)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("AppAccent").opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}
