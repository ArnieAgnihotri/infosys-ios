import SwiftUI

struct TimerRingView: View {
    var body: some View {
        Circle()
            .stroke(.blue.opacity(0.2), lineWidth: 18)
            .frame(width: 220, height: 220)
    }
}
