import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content
    private let elevated: Bool

    init(elevated: Bool = true, @ViewBuilder content: () -> Content) {
        self.elevated = elevated
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color("AppSurface"), Color("AppBackground").opacity(0.72)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("AppAccent").opacity(0.18), lineWidth: 1)
            )
            .shadow(color: elevated ? .black.opacity(0.20) : .clear, radius: elevated ? 8 : 0, y: elevated ? 4 : 0)
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(Color("AppPrimary"))
            Text(value)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .padding(10)
        .background(
            LinearGradient(
                colors: [Color("AppBackground"), Color("AppSurface").opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("AppAccent").opacity(0.14), lineWidth: 1)
        )
    }
}

struct ActionRowCell: View {
    let icon: String
    let title: String
    let subtitle: String?
    let titleColor: Color

    init(icon: String, title: String, subtitle: String? = nil, titleColor: Color = Color("AppTextPrimary")) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.titleColor = titleColor
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Color("AppPrimary"))
                .frame(width: 22, height: 22)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("AppBackground"))
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundStyle(titleColor)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(minHeight: 52)
    }
}
