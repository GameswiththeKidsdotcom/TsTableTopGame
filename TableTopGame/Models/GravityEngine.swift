import Foundation

/// Applies gravity: unsupported pieces fall until they land.
enum GravityEngine {

    /// Returns true if (col, row) is supported (row 15 or has piece below).
    static func isSupported(col: Int, row: Int, in gridState: GridState) -> Bool {
        if row >= Grid.rows - 1 { return true }
        return gridState.isOccupied(col: col, row: row + 1)
    }

    /// Applies one step of gravity. Pieces fall one row if unsupported.
    static func apply(to gridState: inout GridState) -> Bool {
        applyReturningMoves(to: &gridState).changed
    }

    /// Applies one step of gravity; returns changed flag and move deltas for animation.
    /// Each move: (col, fromRow, toRow, color) for a piece that fell one row.
    static func applyReturningMoves(to gridState: inout GridState) -> (changed: Bool, moves: [(col: Int, fromRow: Int, toRow: Int, color: PillColor)]) {
        var moves: [(col: Int, fromRow: Int, toRow: Int, color: PillColor)] = []
        for row in (0..<Grid.rows).reversed() {
            for col in 0..<Grid.columns {
                guard let color = gridState.color(at: col, row: row) else { continue }
                guard !isSupported(col: col, row: row, in: gridState) else { continue }
                gridState.remove(at: col, row: row)
                gridState.set(color, at: col, row: row + 1)
                moves.append((col: col, fromRow: row, toRow: row + 1, color: color))
            }
        }
        return (changed: !moves.isEmpty, moves: moves)
    }

    /// Resolution loop: clear matches, apply gravity, repeat until stable.
    static func resolve(gridState: inout GridState) {
        while true {
            let matches = MatchResolver.findMatches(in: gridState)
            if matches.isEmpty { break }
            for pos in matches {
                gridState.remove(at: pos.col, row: pos.row)
            }
            while apply(to: &gridState) { }
        }
    }
}
