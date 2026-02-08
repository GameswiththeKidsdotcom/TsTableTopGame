import Foundation

// MARK: - Snapshot (C9)

/// Read-only snapshot for AI: current player's grid, capsule colors, valid moves at spawn, virus positions for scoring.
struct AISnapshot {
    let grid: GridState
    let capsuleLeft: PillColor
    let capsuleRight: PillColor
    /// Valid (col, orientation) at spawn row 0.
    let validMoves: [(col: Int, orientation: CapsuleOrientation)]
    /// Virus positions on this grid (for Greedy scoring).
    let virusPositions: Set<GridPosition>
}

// MARK: - Protocol

/// C9: AI returns a single move (col, orientation) at spawn. Returns nil when no valid move (e.g. top-out).
protocol AIController {
    func move(for snapshot: AISnapshot) -> (col: Int, orientation: CapsuleOrientation)?
}

// MARK: - Random AI

/// Picks a random valid (col, orientation). Unit-testable with seeded RNG or by checking legality.
struct RandomAI: AIController {
    func move(for snapshot: AISnapshot) -> (col: Int, orientation: CapsuleOrientation)? {
        guard !snapshot.validMoves.isEmpty else { return nil }
        return snapshot.validMoves.randomElement()
    }
}

// MARK: - Greedy AI (prefer immediate matches)

/// Scores each valid placement by virus cells cleared after simulate-place-and-resolve; picks max; tie-break: smallest col, then first orientation.
struct GreedyAI: AIController {
    func move(for snapshot: AISnapshot) -> (col: Int, orientation: CapsuleOrientation)? {
        guard !snapshot.validMoves.isEmpty else { return nil }
        var bestMove: (col: Int, orientation: CapsuleOrientation)?
        var bestScore = -1
        for move in snapshot.validMoves {
            let score = PlacementScorer.scoreVirusClears(
                grid: snapshot.grid,
                virusPositions: snapshot.virusPositions,
                col: move.col,
                orientation: move.orientation,
                leftColor: snapshot.capsuleLeft,
                rightColor: snapshot.capsuleRight
            )
            if score > bestScore {
                bestScore = score
                bestMove = move
            } else if score == bestScore, let b = bestMove {
                // Tie-break: smallest column, then first orientation (compare by raw value)
                if move.col < b.col || (move.col == b.col && move.orientation.rawValue < b.orientation.rawValue) {
                    bestMove = move
                }
            }
        }
        return bestMove ?? snapshot.validMoves.first
    }
}

// MARK: - Placement scorer (simulate place + resolve, return virus clears)

enum PlacementScorer {
    /// Simulates placing capsule at (col, 0) with orientation, runs match+gravity until stable, returns number of virus positions cleared.
    static func scoreVirusClears(
        grid: GridState,
        virusPositions: Set<GridPosition>,
        col: Int,
        orientation: CapsuleOrientation,
        leftColor: PillColor,
        rightColor: PillColor
    ) -> Int {
        var grid = grid
        var virusPositions = virusPositions
        let segs = MoveValidator.segments(col: col, row: 0, orientation: orientation)
        guard segs.count == 2 else { return 0 }
        grid.set(leftColor, at: segs[0].col, row: segs[0].row)
        grid.set(rightColor, at: segs[1].col, row: segs[1].row)

        var totalCleared = 0
        while true {
            let groups = MatchResolver.findMatchGroups(in: grid)
            if groups.isEmpty { break }
            for (_, positions) in groups {
                for pos in positions {
                    if virusPositions.contains(pos) {
                        totalCleared += 1
                        virusPositions.remove(pos)
                    }
                    grid.remove(at: pos.col, row: pos.row)
                }
            }
            while GravityEngine.apply(to: &grid) { }
        }
        return totalCleared
    }
}
