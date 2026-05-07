import Foundation

@MainActor
final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [FocusTask] = [] {
        didSet {
            saveTasks()
        }
    }

    private let storageKey = "infosys-focus.tasks"

    init() {
        tasks = Self.loadTasks(storageKey: storageKey)
    }

    var openTasks: [FocusTask] {
        tasks.filter { !$0.isDone }
    }

    var completedTasks: [FocusTask] {
        tasks.filter(\.isDone)
    }

    func addTask(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        tasks.insert(FocusTask(title: trimmedTitle), at: 0)
    }

    func toggleTask(_ task: FocusTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
        tasks[index].completedAt = tasks[index].isDone ? .now : nil
    }

    func removeTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    func removeTask(_ task: FocusTask) {
        tasks.removeAll { $0.id == task.id }
    }

    func clearCompleted() {
        tasks.removeAll { $0.isDone }
    }

    private func saveTasks() {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static func loadTasks(storageKey: String) -> [FocusTask] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let savedTasks = try? JSONDecoder().decode([FocusTask].self, from: data)
        else {
            return [
                FocusTask(title: "Plan the next study block"),
                FocusTask(title: "Finish one SwiftUI topic")
            ]
        }

        return savedTasks
    }
}
