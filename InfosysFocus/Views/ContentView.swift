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
                    quickLinks

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
                        statsRow
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

    private var quickLinks: some View {
        HStack(spacing: 12) {
            NavigationLink {
                FocusHistoryView(summaries: pomodoro.dailySummaries, sessions: pomodoro.sessions)
            } label: {
                Label("History", systemImage: "calendar")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            NavigationLink {
                TimerSettingsView(pomodoro: pomodoro)
            } label: {
                Label("Settings", systemImage: "slider.horizontal.3")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
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

    private var statsRow: some View {
        HStack(spacing: 12) {
            statItem(
                title: "Rounds",
                value: "\(pomodoro.completedFocusRounds)",
                symbolName: "checkmark.seal"
            )

            statItem(
                title: "Minutes",
                value: "\(pomodoro.totalFocusMinutes)",
                symbolName: "clock"
            )

            statItem(
                title: "Tasks",
                value: "\(taskStore.completedTasks.count)",
                symbolName: "list.bullet.clipboard"
            )
        }
    }

    private func statItem(title: String, value: String, symbolName: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: symbolName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .monospacedDigit()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
