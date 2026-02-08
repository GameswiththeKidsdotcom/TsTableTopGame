import Foundation
import Combine

/// C8: Observable snapshot for HUD (turn, cash, next capsule). Updated by GameScene.
final class GameStateDisplay: ObservableObject {
    @Published var currentPlayerIndex: Int = 0
    @Published var cash0: Int = 0
    @Published var cash1: Int = 0
    @Published var nextCapsuleLeft: PillColor?
    @Published var nextCapsuleRight: PillColor?
    @Published var phase: GamePhase = .playing

    func update(currentPlayerIndex: Int, cash: [Int], nextCapsule: (PillColor, PillColor)?, phase: GamePhase) {
        self.currentPlayerIndex = currentPlayerIndex
        self.cash0 = cash.count > 0 ? cash[0] : 0
        self.cash1 = cash.count > 1 ? cash[1] : 0
        self.nextCapsuleLeft = nextCapsule?.0
        self.nextCapsuleRight = nextCapsule?.1
        self.phase = phase
    }
}
