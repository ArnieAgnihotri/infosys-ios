import SwiftUI

struct TaskListView: View {
    @ObservedObject var store: TaskStore
    @State private var newTaskTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Tasks", systemImage: "checklist")
                    .font(.headline)

                Spacer()

                if !store.completedTasks.isEmpty {
                    Button("Clear done") {
                        store.clearCompleted()
                    }
                    .font(.caption)
                }
            }

            HStack(spacing: 10) {
                TextField("Add a task", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onSubmit(addTask)

                Button(action: addTask) {
                    Image(systemName: "plus")
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Add task")
            }

            if store.tasks.isEmpty {
                Text("No tasks yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(store.tasks) { task in
                        taskRow(task)
                    }
                }
            }
        }
        .panelBackground()
    }

    private func taskRow(_ task: FocusTask) -> some View {
        HStack(spacing: 12) {
            Button {
                store.toggleTask(task)
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isDone ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isDone ? "Mark task as open" : "Mark task done")

            Text(task.title)
                .font(.body)
                .strikethrough(task.isDone)
                .foregroundStyle(task.isDone ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                store.removeTask(task)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete task")
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func addTask() {
        store.addTask(title: newTaskTitle)
        newTaskTitle = ""
    }
}
