# Infosys Focus

Infosys Focus is a small SwiftUI productivity app built around three things that help during study or work blocks:

- a Pomodoro timer
- a simple task list
- light ambient sound for focus

The app is intentionally simple. It does not require a backend, account, or paid API. Tasks are saved locally on the device and the ambient sounds are generated in-app, so the repository stays lightweight.

## Features

- 25 minute focus timer with short and long breaks
- Start, pause, reset, and skip controls
- Local task list with add, complete, delete, and clear completed actions
- Task persistence using `UserDefaults`
- Ambient sound options for rain, ocean, and deep noise
- Native SwiftUI interface for iPhone and iPad

## Tech Stack

- Swift
- SwiftUI
- AVFoundation
- Xcode 26.2
- iOS 17+

## Project Structure

```text
InfosysFocus/
  Models/
    FocusTask.swift
  Services/
    AmbientAudioController.swift
    TaskStore.swift
  ViewModels/
    PomodoroViewModel.swift
  Views/
    AmbientPickerView.swift
    ContentView.swift
    TaskListView.swift
    TimerRingView.swift
```

## Running the App

1. Open `InfosysFocus.xcodeproj` in Xcode.
2. Select the `InfosysFocus` scheme.
3. Choose an iPhone simulator or a connected iPhone.
4. Press Run.

You can also verify from the terminal:

```sh
xcodebuild -project InfosysFocus.xcodeproj -scheme InfosysFocus -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```

## Notes

- No third-party packages are used.
- Ambient audio is generated with `AVAudioEngine`; there are no bundled music files.
- The app currently stores data only on the device. Cloud sync and notifications are good next improvements.
