import Foundation

@MainActor
final class AmbientAudioController: ObservableObject {
    @Published var isPlaying = false
}
