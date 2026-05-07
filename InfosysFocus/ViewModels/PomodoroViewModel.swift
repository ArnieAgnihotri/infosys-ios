import Foundation
import UIKit
import WidgetKit

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

        var defaultMinutes: Int {
            switch self {
            case .focus: 25
            case .shortBreak: 5
            case .longBreak: 15
            }
        }
    }

    @Published var selectedMode: Mode = .focus {
        didSet {
            guard oldValue != selectedMode, !isRunning else { return }
            secondsRemaining = duration(for: selectedMode)
            saveWidgetState()
        }
    }

    @Published var focusMinutes: Int {
        didSet {
            focusMinutes = Self.clampedMinutes(focusMinutes, range: 10...60)
            saveDurations()
            resetIfIdle(mode: .focus)
        }
    }

    @Published var shortBreakMinutes: Int {
        didSet {
            shortBreakMinutes = Self.clampedMinutes(shortBreakMinutes, range: 3...20)
            saveDurations()
            resetIfIdle(mode: .shortBreak)
        }
    }

    @Published var longBreakMinutes: Int {
        didSet {
            longBreakMinutes = Self.clampedMinutes(longBreakMinutes, range: 10...45)
            saveDurations()
            resetIfIdle(mode: .longBreak)
        }
    }

    @Published private(set) var secondsRemaining: Int = Mode.focus.defaultMinutes * 60
    @Published private(set) var isRunning = false
    @Published private(set) var completedFocusRounds = 0
    @Published private(set) var totalFocusMinutes = 0
    @Published private(set) var lastCompletedAt: Date?
    @Published private(set) var sessions: [FocusSession] = []

    private var timerTask: Task<Void, Never>?
    private let notificationScheduler = NotificationScheduler()
    private let completedRoundsKey = "infosys-focus.completed-rounds"
    private let totalFocusMinutesKey = "infosys-focus.total-focus-minutes"
    private let lastCompletedAtKey = "infosys-focus.last-completed-at"
    private let focusMinutesKey = "infosys-focus.focus-minutes"
    private let shortBreakMinutesKey = "infosys-focus.short-break-minutes"
    private let longBreakMinutesKey = "infosys-focus.long-break-minutes"
    private let sessionsKey = "infosys-focus.sessions"

    init() {
        focusMinutes = Self.savedMinutes(forKey: focusMinutesKey, defaultValue: Mode.focus.defaultMinutes)
        shortBreakMinutes = Self.savedMinutes(forKey: shortBreakMinutesKey, defaultValue: Mode.shortBreak.defaultMinutes)
        longBreakMinutes = Self.savedMinutes(forKey: longBreakMinutesKey, defaultValue: Mode.longBreak.defaultMinutes)
        completedFocusRounds = UserDefaults.standard.integer(forKey: completedRoundsKey)
        totalFocusMinutes = UserDefaults.standard.integer(forKey: totalFocusMinutesKey)
        lastCompletedAt = UserDefaults.standard.object(forKey: lastCompletedAtKey) as? Date
        sessions = Self.loadSessions(storageKey: sessionsKey)
        secondsRemaining = focusMinutes * 60
        saveWidgetState()
    }

    var progress: Double {
        1 - (Double(secondsRemaining) / Double(duration(for: selectedMode)))
    }

    var dailySummaries: [FocusDaySummary] {
        let calendar = Calendar.current
        let groupedSessions = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.endedAt)
        }

        return groupedSessions
            .map { date, sessions in
                FocusDaySummary(
                    date: date,
                    sessions: sessions.count,
                    minutes: sessions.reduce(0) { $0 + $1.minutes }
                )
            }
            .sorted { $0.date > $1.date }
    }

    var timeText: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true

        Task {
            await notificationScheduler.scheduleTimerFinishedNotification(
                after: secondsRemaining,
                modeTitle: selectedMode.title
            )
        }

        saveWidgetState(endDate: Date().addingTimeInterval(TimeInterval(secondsRemaining)))

        timerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self?.tick()
            }
        }
    }

    func pause() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
        notificationScheduler.cancelTimerNotification()
        saveWidgetState()
    }

    func reset() {
        pause()
        secondsRemaining = duration(for: selectedMode)
        saveWidgetState()
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
            recordFocusSession()
            completedFocusRounds += 1
            selectedMode = completedFocusRounds.isMultiple(of: 4) ? .longBreak : .shortBreak
        } else {
            selectedMode = .focus
        }

        pause()
        secondsRemaining = duration(for: selectedMode)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        saveWidgetState()
    }

    private func recordFocusSession() {
        let minutes = duration(for: .focus) / 60
        let endedAt = Date()
        let session = FocusSession(
            startedAt: endedAt.addingTimeInterval(TimeInterval(-duration(for: .focus))),
            endedAt: endedAt,
            minutes: minutes
        )

        sessions.insert(session, at: 0)
        totalFocusMinutes += minutes
        lastCompletedAt = endedAt

        UserDefaults.standard.set(completedFocusRounds + 1, forKey: completedRoundsKey)
        UserDefaults.standard.set(totalFocusMinutes, forKey: totalFocusMinutesKey)
        UserDefaults.standard.set(lastCompletedAt, forKey: lastCompletedAtKey)
        saveSessions()
    }

    func duration(for mode: Mode) -> Int {
        switch mode {
        case .focus:
            focusMinutes * 60
        case .shortBreak:
            shortBreakMinutes * 60
        case .longBreak:
            longBreakMinutes * 60
        }
    }

    private func saveDurations() {
        UserDefaults.standard.set(focusMinutes, forKey: focusMinutesKey)
        UserDefaults.standard.set(shortBreakMinutes, forKey: shortBreakMinutesKey)
        UserDefaults.standard.set(longBreakMinutes, forKey: longBreakMinutesKey)
    }

    private func resetIfIdle(mode: Mode) {
        guard selectedMode == mode, !isRunning else { return }
        secondsRemaining = duration(for: mode)
        saveWidgetState()
    }

    private func saveSessions() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: sessionsKey)
    }

    private static func savedMinutes(forKey key: String, defaultValue: Int) -> Int {
        let value = UserDefaults.standard.integer(forKey: key)
        return value == 0 ? defaultValue : value
    }

    private static func loadSessions(storageKey: String) -> [FocusSession] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let sessions = try? JSONDecoder().decode([FocusSession].self, from: data)
        else {
            return []
        }

        return sessions.sorted { $0.endedAt > $1.endedAt }
    }

    private static func clampedMinutes(_ minutes: Int, range: ClosedRange<Int>) -> Int {
        min(max(minutes, range.lowerBound), range.upperBound)
    }

    private func saveWidgetState(endDate: Date? = nil) {
        SharedFocusStore.save(
            SharedFocusState(
                modeTitle: selectedMode.title,
                isRunning: isRunning,
                secondsRemaining: secondsRemaining,
                totalSeconds: duration(for: selectedMode),
                endDate: endDate,
                completedFocusRounds: completedFocusRounds,
                totalFocusMinutes: totalFocusMinutes,
                updatedAt: .now
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
    }

    deinit {
        timerTask?.cancel()
    }
}
