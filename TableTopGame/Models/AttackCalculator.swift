import Foundation

/// C7: Computes attack (cash, garbage) from cleared matches. Route B: any clear sends garbage.
/// Row-major: horizontal clears first (L→R, T→B), vertical second (T→B, L→R).
enum AttackCalculator {

    /// Result of attack computation for one resolution batch.
    struct AttackResult {
        /// Virus count cleared (1 cash per virus). SPEC: no chain bonus.
        let virusCount: Int
        /// Garbage count to send (min 4). Route B: any clear sends garbage.
        let garbageCount: Int
        /// Colors for garbage (up to 4, from attack registers). Fixed pattern columns.
        let garbageColors: [PillColor]
    }

    /// Compute attack from match groups. Virus positions identify virus clears for cash.
    static func compute(
        matchGroups: [(color: PillColor, positions: Set<GridPosition>)],
        virusPositions: Set<GridPosition>
    ) -> AttackResult {
        var virusCount = 0
        var attackRegisters: [PillColor] = []

        for (color, positions) in matchGroups {
            for pos in positions {
                if virusPositions.contains(pos) {
                    virusCount += 1
                }
            }
            attackRegisters.append(color)
            if attackRegisters.count >= 4 { break }
        }

        let clearCount = matchGroups.count
        let garbageCount = min(max(clearCount, 1), 4)
        let colors = Array(attackRegisters.prefix(garbageCount))
        let paddedColors: [PillColor] = {
            var c = colors
            while c.count < garbageCount {
                c.append(PillColor.allCases.first ?? .red)
            }
            return c
        }()

        return AttackResult(
            virusCount: virusCount,
            garbageCount: clearCount >= 1 ? garbageCount : 0,
            garbageColors: paddedColors
        )
    }

    /// Fixed garbage column patterns. Route B: 2→cols 0,4; 3→0,2,4; 4→0,2,4,6.
    static func garbagePositions(count: Int, colors: [PillColor]) -> [(col: Int, row: Int, color: PillColor)] {
        let cols: [Int]
        switch count {
        case 2: cols = [0, 4]
        case 3: cols = [0, 2, 4]
        case 4: cols = [0, 2, 4, 6]
        default: return []
        }
        return cols.enumerated().map { i, col in
            (col: col, row: 0, color: i < colors.count ? colors[i] : .red)
        }
    }
}
