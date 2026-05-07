import Foundation

@MainActor
final class PomodoroViewModel: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case focus
        case shortBreak
        case longBreak

        var id: String { rawValue }

        var title: String {
            switch self {
            case .focus:
                "Focus"
            case .shortBreak:
                "Short break"
            case .longBreak:
                "Long break"
            }
        }

        var duration: Int {
            switch self {
            case .focus:
                25 * 60
            case .shortBreak:
                5 * 60
            case .longBreak:
                15 * 60
            }
        }
    }

    @Published var selectedMode: Mode = .focus {
        didSet {
            guard oldValue != selectedMode, !isRunning else { return }
            secondsRemaining = selectedMode.duration
        }
    }

    @Published private(set) var secondsRemaining: Int = Mode.focus.duration
    @Published private(set) var isRunning = false
    @Published private(set) var completedFocusRounds = 0

    private var timerTask: Task<Void, Never>?

    var progress: Double {
        1 - (Double(secondsRemaining) / Double(selectedMode.duration))
    }

    var timeText: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await self?.tick()
            }
        }
    }

    func pause() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    func reset() {
        pause()
        secondsRemaining = selectedMode.duration
    }

    func skip() {
        completeCurrentMode()
    }

    private func tick() {
        guard isRunning else { return }

        if secondsRemaining > 1 {
            secondsRemaining -= 1
        } else {
            completeCurrentMode()
        }
    }

    private func completeCurrentMode() {
        if selectedMode == .focus {
            completedFocusRounds += 1
            selectedMode = completedFocusRounds.isMultiple(of: 4) ? .longBreak : .shortBreak
        } else {
            selectedMode = .focus
        }

        pause()
        secondsRemaining = selectedMode.duration
    }

    deinit {
        timerTask?.cancel()
    }
}
