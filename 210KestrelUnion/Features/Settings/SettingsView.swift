import SwiftUI
import UIKit
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppStorageStore
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    statsCard
                    settingsRows
                    versionFooter
                }
                .padding(16)
            }
            .background(AppBackgroundView())
            .navigationTitle("Settings")
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    FeedbackService.warning()
                    store.resetAllData()
                    NotificationCenter.default.post(name: .dataReset, object: nil)
                }
            } message: {
                Text("This action clears reflections, progress, and achievements.")
            }
        }
    }

    private var statsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Stats")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 10) {
                    MetricTile(title: "Entries", value: "\(store.entriesCreated)", icon: "book.fill")
                    MetricTile(title: "Minutes", value: "\(store.totalMinutesUsed)", icon: "clock.fill")
                    MetricTile(title: "Streak", value: "\(store.streakDays)", icon: "flame.fill")
                }
            }
        }
    }

    private var settingsRows: some View {
        AppCard {
            VStack(spacing: 0) {
                Button {
                    FeedbackService.tap()
                    rateApp()
                } label: {
                    ActionRowCell(icon: "star.bubble.fill", title: "Rate Us", subtitle: "Share your app experience")
                }
                divider
                Button {
                    FeedbackService.tap()
                    openPrivacyPolicy()
                } label: {
                    ActionRowCell(icon: "lock.doc.fill", title: "Privacy", subtitle: "View privacy policy")
                }
                divider
                Button {
                    FeedbackService.tap()
                    openTerms()
                } label: {
                    ActionRowCell(icon: "doc.text.fill", title: "Terms", subtitle: "View terms and conditions")
                }
                divider
                Button {
                    FeedbackService.tap()
                    showResetAlert = true
                } label: {
                    ActionRowCell(icon: "trash.fill", title: "Reset All Data", subtitle: "Clear all local progress", titleColor: .red)
                }
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color("AppBackground"))
            .frame(height: 1)
            .padding(.horizontal, 12)
    }

    private var versionFooter: some View {
        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
            .font(.footnote)
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: AppLinks.privacyPolicy.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        if let url = URL(string: AppLinks.terms.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
