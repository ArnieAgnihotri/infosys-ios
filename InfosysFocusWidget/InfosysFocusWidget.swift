import SwiftUI
import WidgetKit

struct FocusWidgetEntry: TimelineEntry {
    let date: Date
    let state: SharedFocusState
}

struct FocusWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FocusWidgetEntry {
        FocusWidgetEntry(date: .now, state: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (FocusWidgetEntry) -> Void) {
        completion(FocusWidgetEntry(date: .now, state: SharedFocusStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FocusWidgetEntry>) -> Void) {
        let state = SharedFocusStore.load()
        let entry = FocusWidgetEntry(date: .now, state: state)
        let refreshDate = state.endDate?.addingTimeInterval(2) ?? Date().addingTimeInterval(15 * 60)
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }
}

struct InfosysFocusWidgetView: View {
    let entry: FocusWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: entry.state.isRunning ? "timer" : "checkmark.seal")
                    .foregroundStyle(.orange)

                Text(entry.state.modeTitle)
                    .font(.headline)
                    .lineLimit(1)
            }

            timerText
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.7)

            Spacer(minLength: 4)

            HStack(spacing: 10) {
                stat("\(entry.state.completedFocusRounds)", "rounds")
                stat("\(entry.state.totalFocusMinutes)", "min")
            }
        }
        .containerBackground(.background, for: .widget)
    }

    @ViewBuilder
    private var timerText: some View {
        if entry.state.isRunning, let endDate = entry.state.endDate {
            Text(timerInterval: Date()...max(endDate, Date().addingTimeInterval(1)), countsDown: true)
        } else {
            Text(formattedTime(entry.state.secondsRemaining))
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .monospacedDigit()

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

@main
struct InfosysFocusWidget: Widget {
    let kind = "InfosysFocusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FocusWidgetProvider()) { entry in
            InfosysFocusWidgetView(entry: entry)
        }
        .configurationDisplayName("Infosys Focus")
        .description("See the current Pomodoro timer and focus totals.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
