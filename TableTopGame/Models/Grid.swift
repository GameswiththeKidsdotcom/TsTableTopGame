import Foundation

/// 8×16 game grid. SPEC: origin top-left, row 0=spawn, cols 0–7.
struct Grid {
    static let columns = 8
    static let rows = 16

    /// Returns true if (col, row) is within bounds.
    static func isValid(col: Int, row: Int) -> Bool {
        col >= 0 && col < columns && row >= 0 && row < rows
    }
}
