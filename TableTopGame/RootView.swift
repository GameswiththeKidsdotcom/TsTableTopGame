import SwiftUI

/// C10: App phase – menu or playing. Drives coordinator root.
enum AppPhase {
    case menu
    case playing
}

/// E2E: Test-only launch arg -GameOverFixture win|lose|tie shows overlay without playing.
private func gameOverFixtureFromLaunchArguments() -> (winnerId: Int?, isTie: Bool)? {
    let args = ProcessInfo.processInfo.arguments
    if args.contains("-GameOverFixture") {
        if args.contains("win") { return (0, false) }
        if args.contains("lose") { return (1, false) }
        if args.contains("tie") { return (nil, true) }
    }
    return nil
}

/// E2E: Overlay-only view matching GameOverOverlay for -GameOverFixture launch arg.
struct GameOverFixtureView: View {
    let winnerId: Int?
    let isTie: Bool
    let onRestart: () -> Void
    let onReturnToMenu: () -> Void

    private var titleText: String {
        if isTie { return "Tie!" }
        if let id = winnerId { return "Player \(id + 1) wins!" }
        return "Game Over"
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Text(titleText)
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                HStack(spacing: 32) {
                    Text("P1: $0")
                        .foregroundStyle(.white)
                    Text("P2: $0")
                        .foregroundStyle(.white)
                }
                .font(.title2)
                HStack(spacing: 16) {
                    Button("Restart") { onRestart() }
                        .font(.headline)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                        .accessibilityIdentifier("restartButton")
                    Button("Return to Menu") { onReturnToMenu() }
                        .font(.headline)
                        .padding()
                        .background(Color.gray)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                        .accessibilityIdentifier("returnToMenuButton")
                }
            }
        }
    }
}

/// C10: Root coordinator. Switches between MenuView and GameView.
struct RootView: View {
    @State private var appPhase: AppPhase = .menu
    @State private var showSettings = false
    @State private var gameOverFixture: (winnerId: Int?, isTie: Bool)? = nil

    var body: some View {
        Group {
            if let fixture = gameOverFixture {
                GameOverFixtureView(
                    winnerId: fixture.winnerId,
                    isTie: fixture.isTie,
                    onRestart: { gameOverFixture = nil; appPhase = .playing },
                    onReturnToMenu: { gameOverFixture = nil; appPhase = .menu }
                )
            } else {
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
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            if let fixture = gameOverFixtureFromLaunchArguments() {
                gameOverFixture = fixture
            }
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
