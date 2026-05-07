import SwiftUI

struct TimerSettingsView: View {
    @ObservedObject var pomodoro: PomodoroViewModel

    var body: some View {
        Form {
            Section("Timer lengths") {
                durationStepper(
                    title: "Focus",
                    minutes: $pomodoro.focusMinutes,
                    range: 10...60
                )

                durationStepper(
                    title: "Short break",
                    minutes: $pomodoro.shortBreakMinutes,
                    range: 3...20
                )

                durationStepper(
                    title: "Long break",
                    minutes: $pomodoro.longBreakMinutes,
                    range: 10...45
                )
            }
            .disabled(pomodoro.isRunning)

            Section {
                Text(pomodoro.isRunning ? "Pause or reset the current timer before changing durations." : "Changes apply immediately when the timer is not running.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Timer Settings")
    }

    private func durationStepper(
        title: String,
        minutes: Binding<Int>,
        range: ClosedRange<Int>
    ) -> some View {
        Stepper(value: minutes, in: range) {
            HStack {
                Text(title)
                Spacer()
                Text("\(minutes.wrappedValue) min")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}
