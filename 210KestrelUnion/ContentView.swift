//
//  ContentView.swift
//  210KestrelUnion
//
//  Created by Roman on 6/6/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStorageStore()
    @StateObject private var bannerCenter = AchievementBannerCenter()
    @StateObject private var tabRouter = TabRouter()

    var body: some View {
        ZStack(alignment: .top) {
            if store.hasSeenOnboarding {
                mainTabs
                    .environmentObject(store)
                    .environmentObject(bannerCenter)
                    .environmentObject(tabRouter)
            } else {
                OnboardingView {
                    store.markOnboardingComplete()
                }
            }

            if bannerCenter.isVisible, let achievement = bannerCenter.current {
                AchievementBannerView(achievement: achievement)
                    .padding(.top, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: bannerCenter.isVisible)
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            tabRouter.selectedTab = .reflections
        }
    }

    private var mainTabs: some View {
        VStack(spacing: 0) {
            Group {
                switch tabRouter.selectedTab {
                case .reflections:
                    HomeView()
                case .wellness:
                    WellnessHubView()
                case .achievements:
                    AchievementsView()
                case .settings:
                    SettingsView()
                }
            }
            customTabBar
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 10) {
            ForEach(RootTab.allCases, id: \.self) { tab in
                Button {
                    FeedbackService.tap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        tabRouter.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(tabRouter.selectedTab == tab ? Color("AppBackground").opacity(0.15) : Color.clear)
                            )
                        Text(tab.title)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(tabRouter.selectedTab == tab ? Color("AppBackground") : Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tabRouter.selectedTab == tab ? Color("AppPrimary") : Color.clear)
                    )
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [Color("AppSurface"), Color("AppBackground").opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .shadow(color: .black.opacity(0.18), radius: 8, y: -2)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color("AppAccent").opacity(0.15))
                .frame(height: 1)
        }
    }
}

#Preview {
    ContentView()
}
