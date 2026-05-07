import SwiftUI

struct TimerRingView: View {
    let progress: Double
    let timeText: String
    let modeTitle: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 16)

            Circle()
                .trim(from: 0, to: max(0.01, progress))
                .stroke(
                    AngularGradient(
                        colors: [.orange, .pink, .teal, .orange],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.snappy, value: progress)

            VStack(spacing: 8) {
                Text(modeTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(timeText)
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
        }
        .frame(width: 250, height: 250)
        .frame(maxWidth: .infinity)
    }
}
