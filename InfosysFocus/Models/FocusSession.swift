import Foundation

struct FocusSession: Identifiable, Codable, Equatable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date
    let minutes: Int

    init(id: UUID = UUID(), startedAt: Date, endedAt: Date, minutes: Int) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.minutes = minutes
    }
}

struct FocusDaySummary: Identifiable, Equatable {
    let date: Date
    let sessions: Int
    let minutes: Int

    var id: Date { date }
}
