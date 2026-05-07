import SwiftUI

struct AmbientPickerView: View {
    @ObservedObject var audioController: AmbientAudioController

    var body: some View {
        Toggle("Ambient sound", isOn: $audioController.isPlaying)
    }
}
