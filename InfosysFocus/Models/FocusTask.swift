import Foundation

struct FocusTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isDone: Bool
    var createdAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        isDone: Bool = false,
        createdAt: Date = .now,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}
