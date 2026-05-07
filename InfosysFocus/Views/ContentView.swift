import SwiftUI

struct ContentView: View {
    @StateObject private var pomodoro = PomodoroViewModel()
    @StateObject private var taskStore = TaskStore()
    @StateObject private var audioController = AmbientAudioController()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    VStack(spacing: 18) {
                        Picker("Timer mode", selection: $pomodoro.selectedMode) {
                            ForEach(PomodoroViewModel.Mode.allCases) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(pomodoro.isRunning)

                        TimerRingView(
                            progress: pomodoro.progress,
                            timeText: pomodoro.timeText,
                            modeTitle: pomodoro.selectedMode.title
                        )

                        timerControls
                    }
                    .panelBackground()

                    TaskListView(store: taskStore)
                    AmbientPickerView(audioController: audioController)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Infosys Focus")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("One thing at a time.")
                .font(.title)
                .fontWeight(.bold)

            Text("\(taskStore.openTasks.count) open tasks • \(pomodoro.completedFocusRounds) focus rounds")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var timerControls: some View {
        HStack(spacing: 14) {
            Button {
                pomodoro.isRunning ? pomodoro.pause() : pomodoro.start()
            } label: {
                Label(pomodoro.isRunning ? "Pause" : "Start", systemImage: pomodoro.isRunning ? "pause.fill" : "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                pomodoro.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Reset timer")

            Button {
                pomodoro.skip()
            } label: {
                Image(systemName: "forward.fill")
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Skip timer")
        }
    }
}

#Preview {
    ContentView()
}

extension View {
    func panelBackground() -> some View {
        padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
