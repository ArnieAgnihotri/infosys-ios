import SwiftUI

struct AmbientPickerView: View {
    @ObservedObject var audioController: AmbientAudioController

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Ambient", systemImage: "speaker.wave.2")
                    .font(.headline)

                Spacer()

                Button {
                    audioController.setPlaying(!audioController.isPlaying)
                } label: {
                    Label(
                        audioController.isPlaying ? "Stop" : "Play",
                        systemImage: audioController.isPlaying ? "stop.fill" : "play.fill"
                    )
                }
                .buttonStyle(.borderedProminent)
            }

            Picker("Sound", selection: $audioController.selectedTrack) {
                ForEach(AmbientTrack.allCases) { track in
                    Label(track.title, systemImage: track.symbolName)
                        .tag(track)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Image(systemName: "speaker")
                    .foregroundStyle(.secondary)

                Slider(value: $audioController.volume, in: 0.05...0.8)

                Image(systemName: "speaker.wave.3")
                    .foregroundStyle(.secondary)
            }

            if let playbackError = audioController.playbackError {
                Text(playbackError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .panelBackground()
    }
}
