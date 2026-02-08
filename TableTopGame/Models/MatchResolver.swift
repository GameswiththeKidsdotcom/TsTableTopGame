import Foundation

/// Detects 4-in-a-row (horizontal or vertical) matches.
enum MatchResolver {

    /// Returns match groups in row-major order (horizontal L→R T→B, then vertical T→B L→R).
    /// C7: Used by AttackCalculator for attack registers. Overlapping groups (e.g. L-shape) count separately.
    static func findMatchGroups(in gridState: GridState) -> [(color: PillColor, positions: Set<GridPosition>)] {
        var groups: [(color: PillColor, positions: Set<GridPosition>)] = []
        var seenGroups: Set<Set<GridPosition>> = []

        for row in 0..<Grid.rows {
            for col in 0..<Grid.columns {
                guard let color = gridState.color(at: col, row: row) else { continue }
                let h = scanLine(col: col, row: row, dCol: 1, dRow: 0, color: color, in: gridState)
                if !h.isEmpty, !seenGroups.contains(h) {
                    seenGroups.insert(h)
                    groups.append((color, h))
                }
            }
        }
        for col in 0..<Grid.columns {
            for row in 0..<Grid.rows {
                guard let color = gridState.color(at: col, row: row) else { continue }
                let v = scanLine(col: col, row: row, dCol: 0, dRow: 1, color: color, in: gridState)
                if !v.isEmpty, !seenGroups.contains(v) {
                    seenGroups.insert(v)
                    groups.append((color, v))
                }
            }
        }
        return groups
    }

    /// Returns all (col, row) positions that are part of a 4+ match.
    static func findMatches(in gridState: GridState) -> Set<GridPosition> {
        var matched = Set<GridPosition>()
        for row in 0..<Grid.rows {
            for col in 0..<Grid.columns {
                guard let color = gridState.color(at: col, row: row) else { continue }
                let horizontal = scanLine(col: col, row: row, dCol: 1, dRow: 0, color: color, in: gridState)
                let vertical = scanLine(col: col, row: row, dCol: 0, dRow: 1, color: color, in: gridState)
                matched.formUnion(horizontal)
                matched.formUnion(vertical)
            }
        }
        return matched
    }

    private static func scanLine(col: Int, row: Int, dCol: Int, dRow: Int, color: PillColor, in gridState: GridState) -> Set<GridPosition> {
        var count = 0
        var positions: [GridPosition] = []
        var c = col, r = row
        while Grid.isValid(col: c, row: r), gridState.color(at: c, row: r) == color {
            count += 1
            positions.append(GridPosition(col: c, row: r))
            c += dCol
            r += dRow
        }
        if count >= 4 {
            return Set(positions)
        }
        return []
    }
}
