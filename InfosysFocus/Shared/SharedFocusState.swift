import Foundation

struct SharedFocusState: Codable, Equatable {
    static let appGroupIdentifier = "group.com.arnav.infosysfocus"

    let modeTitle: String
    let isRunning: Bool
    let secondsRemaining: Int
    let totalSeconds: Int
    let endDate: Date?
    let completedFocusRounds: Int
    let totalFocusMinutes: Int
    let updatedAt: Date

    static let placeholder = SharedFocusState(
        modeTitle: "Focus",
        isRunning: false,
        secondsRemaining: 25 * 60,
        totalSeconds: 25 * 60,
        endDate: nil,
        completedFocusRounds: 0,
        totalFocusMinutes: 0,
        updatedAt: .now
    )
}

enum SharedFocusStore {
    private static let stateKey = "infosys-focus.widget-state"

    static func save(_ state: SharedFocusState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: stateKey)
        appGroupDefaults?.set(data, forKey: stateKey)
    }

    static func load() -> SharedFocusState {
        let data = appGroupDefaults?.data(forKey: stateKey) ?? UserDefaults.standard.data(forKey: stateKey)
        guard
            let data,
            let state = try? JSONDecoder().decode(SharedFocusState.self, from: data)
        else {
            return .placeholder
        }

        return state
    }

    private static var appGroupDefaults: UserDefaults? {
        UserDefaults(suiteName: SharedFocusState.appGroupIdentifier)
    }
}
