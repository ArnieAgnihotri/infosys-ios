import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text("Infosys Focus")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .navigationTitle("Focus")
        }
    }
}

#Preview {
    ContentView()
}
