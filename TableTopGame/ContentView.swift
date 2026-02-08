import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var stateDisplay = GameStateDisplay()
    @State private var scene: GameScene?

    var body: some View {
        ZStack(alignment: .top) {
            if let scene = scene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
            }

            // C8: HUD overlay – turn, cash, next capsule.
            HUDOverlay(display: stateDisplay)
        }
        .onAppear {
            if scene == nil {
                let s = GameScene()
                s.scaleMode = .resizeFill
                s.stateDisplay = stateDisplay
                scene = s
            }
        }
    }
}

/// C8: Turn indicator, cash for both players, next capsule preview.
private struct HUDOverlay: View {
    @ObservedObject var display: GameStateDisplay

    var body: some View {
        VStack(spacing: 8) {
            if case .gameOver(let winnerId, let isTie) = display.phase {
                Text(isTie ? "Tie!" : (winnerId != nil ? "Player \(winnerId! + 1) wins!" : "Game Over"))
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
    ContentView()
}
