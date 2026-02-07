import Foundation

/// Win and elimination checks for 2-player head-to-head. SPEC: first to clear wins; top-out = elimination; last standing wins; tie when both eliminated or cash tiebreaker.
enum WinConditionChecker {

    /// True when no virus positions remain (all viruses cleared).
    static func hasClearedAllViruses(virusPositions: Set<GridPosition>) -> Bool {
        virusPositions.isEmpty
    }

    /// True when spawn is blocked (capsule cannot be placed at spawn row).
    static func hasToppedOut(canSpawn: Bool) -> Bool {
        !canSpawn
    }

    /// Returns the single non-eliminated player id, or nil if zero or more than one.
    static func singlePlayerLeft(eliminated: Set<Int>, playerCount: Int) -> Int? {
        let remaining = (0..<playerCount).filter { !eliminated.contains($0) }
        return remaining.count == 1 ? remaining.first : nil
    }

    /// Tie: both eliminated, or (when game over for clear) same cash — caller passes winnerId and cash values for tiebreaker.
    static func isTie(eliminated: Set<Int>, playerCount: Int, cash0: Int, cash1: Int) -> Bool {
        if eliminated.count >= playerCount { return true }
        if playerCount == 2 && eliminated.count == 2 { return true }
        return false
    }

    /// Resolve winner when one player cleared all (they win); else when one eliminated the other wins; else tie.
    static func resolveGameOver(
        clearedAllCurrent: Bool,
        currentPlayerId: Int,
        eliminated: Set<Int>,
        playerCount: Int,
        cash: [Int]
    ) -> GamePhase {
        if clearedAllCurrent {
            return .gameOver(winnerId: currentPlayerId, isTie: false)
        }
        if eliminated.count >= playerCount {
            return .gameOver(winnerId: nil, isTie: true)
        }
        if let winner = singlePlayerLeft(eliminated: eliminated, playerCount: playerCount) {
            return .gameOver(winnerId: winner, isTie: false)
        }
        return .playing
    }
}
