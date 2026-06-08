import SwiftUI
import AudioToolbox

struct CalmFocusView: View {
    @EnvironmentObject private var store: AppStorageStore
    @EnvironmentObject private var banners: AchievementBannerCenter
    @StateObject private var viewModel = CalmFocusViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var pulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Calm Focus")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Follow the 4-7-8 rhythm and let each breath settle your focus.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .padding(.top, 8)
                
                presetCard
                sessionStatsCard

                if store.breathSessionsCompleted == 0, viewModel.isRunning == false {
                    AppCard {
                        VStack(spacing: 12) {
                            AppIllustrationView(art: .calmFocus, cornerRadius: 14)
                                .frame(height: 140)
                            Text("No sessions yet")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Start your first breathing session")
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                }

                Text(viewModel.currentPhaseTitle)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppPrimary"))
                    .frame(maxWidth: .infinity, alignment: .center)

                ZStack {
                    Circle()
                        .fill(Color("AppAccent").opacity(0.25))
                        .frame(width: 220, height: 220)
                        .scaleEffect(viewModel.currentPhaseTitle == "Inhale" ? (pulse ? 1.05 : 0.8) : 0.9)
                        .animation(.easeInOut(duration: 1), value: pulse)
                    Circle()
                        .stroke(Color("AppPrimary"), lineWidth: 4)
                        .frame(width: 180, height: 180)
                        .scaleEffect(viewModel.currentPhaseTitle == "Inhale" ? (pulse ? 1.2 : 0.8) : viewModel.currentPhaseTitle == "Exhale" ? 0.9 : 1)
                        .animation(.easeInOut(duration: Double(viewModel.phaseSecondsRemaining)), value: viewModel.phaseSecondsRemaining)
                    Text("\(viewModel.phaseSecondsRemaining)s")
                        .font(.title.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .frame(height: 260)

                Text("Elapsed: \(formatTime(viewModel.elapsedSeconds))")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                
                AppCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Current Cycle")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        ForEach(store.breathingSteps(), id: \.id) { step in
                            HStack {
                                Text(step.title)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Spacer()
                                Text("\(step.seconds)s")
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }
                    }
                }

                Button {
                    if viewModel.isRunning {
                        FeedbackService.mediumImpact()
                        let minutes = viewModel.stop()
                        store.completeBreathingSession(minutes: minutes)
                        let newAchievements = store.evaluateAchievements()
                        if newAchievements.isEmpty == false {
                            FeedbackService.success()
                            banners.enqueue(newAchievements)
                        } else {
                            FeedbackService.success()
                        }
                    } else {
                        FeedbackService.mediumImpact()
                        viewModel.start(with: store.breathingSteps())
                        AudioServicesPlaySystemSound(1003)
                    }
                } label: {
                    Text(viewModel.isRunning ? "Stop Session" : "Begin")
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
                .padding(.top, 4)
            }
            .padding(16)
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                viewModel.resumeIfNeeded()
            } else {
                viewModel.pause()
            }
        }
        .onAppear {
            pulse = true
        }
        .overlay(alignment: .center) {
            SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccess)
        }
    }

    private var presetCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Breathing Pattern")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Picker("Preset", selection: $store.selectedBreathingPreset) {
                    ForEach(BreathingPresetType.allCases) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .pickerStyle(.segmented)

                if store.selectedBreathingPreset == .custom {
                    Stepper("Inhale: \(store.customBreathingPreset.inhale)s", value: $store.customBreathingPreset.inhale, in: 1...10)
                    Stepper("Hold: \(store.customBreathingPreset.hold)s", value: $store.customBreathingPreset.hold, in: 1...10)
                    Stepper("Exhale: \(store.customBreathingPreset.exhale)s", value: $store.customBreathingPreset.exhale, in: 1...10)
                    Stepper("Second Hold: \(store.customBreathingPreset.secondHold)s", value: $store.customBreathingPreset.secondHold, in: 0...10)
                }
            }
        }
    }

    private var sessionStatsCard: some View {
        AppCard {
            HStack(spacing: 10) {
                MetricTile(title: "Sessions", value: "\(store.breathSessionsCompleted)", icon: "lungs.fill")
                MetricTile(title: "Minutes", value: "\(store.totalMinutesPracticed)", icon: "clock.fill")
                MetricTile(title: "Streak", value: "\(store.streakDays)", icon: "flame.fill")
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remaining = seconds % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }
}
