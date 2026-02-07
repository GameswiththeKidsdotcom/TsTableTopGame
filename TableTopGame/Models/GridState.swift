import Foundation

/// A position on the 8×16 grid.
struct GridPosition: Hashable, Equatable {
    let col: Int
    let row: Int
}

/// Occupied cells: viruses and locked pill halves. Keyed by (col, row).
struct GridState {
    private(set) var occupied: [GridPosition: PillColor] = [:]

    mutating func set(_ color: PillColor, at col: Int, row: Int) {
        guard Grid.isValid(col: col, row: row) else { return }
        occupied[GridPosition(col: col, row: row)] = color
    }

    mutating func remove(at col: Int, row: Int) {
        occupied.removeValue(forKey: GridPosition(col: col, row: row))
    }

    func isOccupied(col: Int, row: Int) -> Bool {
        occupied[GridPosition(col: col, row: row)] != nil
    }

    func color(at col: Int, row: Int) -> PillColor? {
        occupied[GridPosition(col: col, row: row)]
    }

    mutating func addViruses(_ viruses: [Virus]) {
        for v in viruses {
            set(v.color, at: v.col, row: v.row)
        }
    }
}
