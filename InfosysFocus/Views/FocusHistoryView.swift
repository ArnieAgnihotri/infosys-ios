import SwiftUI

struct FocusHistoryView: View {
    let summaries: [FocusDaySummary]
    let sessions: [FocusSession]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        List {
            if summaries.isEmpty {
                ContentUnavailableView(
                    "No focus sessions yet",
                    systemImage: "clock.badge.checkmark",
                    description: Text("Completed focus timers will appear here.")
                )
            } else {
                Section("Daily summary") {
                    ForEach(summaries) { summary in
                        HStack {
                            Text(dateFormatter.string(from: summary.date))
                            Spacer()
                            Text("\(summary.sessions) sessions • \(summary.minutes) min")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Recent sessions") {
                    ForEach(sessions.prefix(20)) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dateFormatter.string(from: session.endedAt))
                                .font(.headline)

                            Text("\(timeFormatter.string(from: session.startedAt)) - \(timeFormatter.string(from: session.endedAt)) • \(session.minutes) min")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Focus History")
    }
}
