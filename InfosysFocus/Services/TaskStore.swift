import Foundation

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [FocusTask] = []

    init() {
        tasks = [
            FocusTask(title: "Prepare Pomodoro notes"),
            FocusTask(title: "Review one SwiftUI concept")
        ]
    }

    func addTask(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        tasks.insert(FocusTask(title: trimmedTitle), at: 0)
    }

    func toggleTask(_ task: FocusTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
    }

    func removeTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}
