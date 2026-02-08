import SwiftUI

/// C10: App phase – menu or playing. Drives coordinator root.
enum AppPhase {
    case menu
    case playing
}

/// C10: Root coordinator. Switches between MenuView and GameView.
struct RootView: View {
    @State private var appPhase: AppPhase = .menu
    @State private var showSettings = false

    var body: some View {
        Group {
            switch appPhase {
            case .menu:
                MenuView(
                    onNewGame: { appPhase = .playing },
                    onSettings: { showSettings = true }
                )
            case .playing:
                GameView(
                    onRestart: { appPhase = .playing },
                    onReturnToMenu: { appPhase = .menu }
                )
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

/// C10: Main menu with New Game and Settings.
struct MenuView: View {
    let onNewGame: () -> Void
    let onSettings: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("TableTopGame")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                Button("New Game") {
                    onNewGame()
                }
                .font(.headline)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .cornerRadius(8)
                .accessibilityIdentifier("newGameButton")
                Button("Settings") {
                    onSettings()
                }
                .font(.headline)
                .foregroundStyle(.white)
                .accessibilityIdentifier("settingsButton")
            }
        }
    }
}
