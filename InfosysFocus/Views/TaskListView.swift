import SwiftUI

struct TaskListView: View {
    @ObservedObject var store: TaskStore

    var body: some View {
        List {
            ForEach(store.tasks) { task in
                Text(task.title)
            }
        }
    }
}
