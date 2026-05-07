import Foundation

@MainActor
final class PomodoroViewModel: ObservableObject {
    @Published var secondsRemaining: Int = 25 * 60
}
