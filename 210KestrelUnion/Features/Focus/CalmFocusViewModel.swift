import Foundation
import Combine

final class CalmFocusViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedSeconds = 0
    @Published var currentPhaseTitle = "Inhale"
    @Published var phaseSecondsRemaining = 4
    @Published var showSuccess = false

    private var timerCancellable: AnyCancellable?
    private var currentStepIndex = 0
    private var steps: [BreathingStep] = []

    func start(with steps: [BreathingStep]) {
        guard steps.isEmpty == false else { return }
        self.steps = steps
        isRunning = true
        elapsedSeconds = 0
        currentStepIndex = 0
        currentPhaseTitle = steps[0].title
        phaseSecondsRemaining = steps[0].seconds
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() -> Int {
        timerCancellable?.cancel()
        timerCancellable = nil
        isRunning = false
        let totalMinutes = max(1, Int(ceil(Double(elapsedSeconds) / 60.0)))
        if elapsedSeconds > 0 {
            showSuccess = true
        }
        return totalMinutes
    }

    func pause() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func resumeIfNeeded() {
        guard isRunning, timerCancellable == nil else { return }
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        elapsedSeconds += 1
        guard steps.isEmpty == false else { return }
        if phaseSecondsRemaining > 1 {
            phaseSecondsRemaining -= 1
            return
        }
        currentStepIndex = (currentStepIndex + 1) % steps.count
        currentPhaseTitle = steps[currentStepIndex].title
        phaseSecondsRemaining = steps[currentStepIndex].seconds
    }
}
