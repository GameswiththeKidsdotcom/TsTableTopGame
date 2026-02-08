import SwiftUI
import SpriteKit

/// C10: Game view – SpriteView + HUD + GameOverOverlay. Receives onRestart and onReturnToMenu.
struct GameView: View {
    @StateObject private var stateDisplay = GameStateDisplay()
    @State private var scene: GameScene?

    let onRestart: () -> Void
    let onReturnToMenu: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
            }

            HUDOverlay(display: stateDisplay)

            if case .gameOver = stateDisplay.phase {
                GameOverOverlay(
                    display: stateDisplay,
                    onRestart: {
                        startNewGame()
                        onRestart()
                    },
                    onReturnToMenu: onReturnToMenu
                )
            }
        }
        .onAppear {
            if scene == nil {
                startNewGame()
            }
        }
    }

    private func startNewGame() {
        let s = GameScene()
        s.scaleMode = .resizeFill
        s.stateDisplay = stateDisplay
        scene = s
    }
}

/// C10: Game over overlay – winner, stats, Restart and Return to Menu.
struct GameOverOverlay: View {
    @ObservedObject var display: GameStateDisplay
    let onRestart: () -> Void
    let onReturnToMenu: () -> Void

    var body: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
        VStack(spacing: 24) {
            if case .gameOver(let winnerId, let isTie) = display.phase {
                Text(isTie ? "Tie!" : (winnerId != nil ? "Player \(winnerId! + 1) wins!" : "Game Over"))
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
            HStack(spacing: 32) {
                Text("P1: $\(display.cash0)")
                    .foregroundStyle(.white)
                Text("P2: $\(display.cash1)")
                    .foregroundStyle(.white)
            }
            .font(.title2)
            HStack(spacing: 16) {
                Button("Restart") {
                    onRestart()
                }
                .font(.headline)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .cornerRadius(8)
                .accessibilityIdentifier("restartButton")
                Button("Return to Menu") {
                    onReturnToMenu()
                }
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

/// C8: Turn indicator, cash for both players, next capsule preview.
private struct HUDOverlay: View {
    @ObservedObject var display: GameStateDisplay

    var body: some View {
        VStack(spacing: 8) {
            if case .gameOver = display.phase {
                Text("Game Over")
                    .font(.headline)
                    .foregroundStyle(.white)
            } else {
                Text("Player \(display.currentPlayerIndex + 1)'s turn")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            HStack(spacing: 24) {
                Text("P1: $\(display.cash0)")
                    .foregroundStyle(.white)
                Text("P2: $\(display.cash1)")
                    .foregroundStyle(.white)
            }
            .font(.subheadline)
            if let l = display.nextCapsuleLeft, let r = display.nextCapsuleRight {
                HStack(spacing: 4) {
                    pillColorView(l)
                    pillColorView(r)
                }
                .padding(4)
            }
            Text("Pill: tap inside the active board (highlighted). Left 25% = move left · right 25% = move right · top 20% = drop · middle = rotate (Simulator: mouse click)")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .background(.black.opacity(0.6))
        .cornerRadius(8)
        .padding(.top, 8)
    }

    private func pillColorView(_ color: PillColor) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(pillColorSwiftUI(color))
            .frame(width: 16, height: 16)
    }

    private func pillColorSwiftUI(_ color: PillColor) -> Color {
        switch color {
        case .red: return .red
        case .blue: return .blue
        case .yellow: return .yellow
        }
    }
}

#Preview {
    GameView(onRestart: {}, onReturnToMenu: {})
}
