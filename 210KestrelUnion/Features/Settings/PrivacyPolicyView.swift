import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    private var policyText: String {
        guard
            let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
            let content = try? String(contentsOf: url)
        else {
            return "Privacy policy is unavailable."
        }
        return content
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Markdown(policyText)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .tint(Color("AppPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
            }
            .background(AppBackgroundView())
            .navigationTitle("Privacy Policy")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        FeedbackService.tap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }
}
