import Foundation

/// Test fixtures for match and gravity. See docs/FIXTURES.md.
enum Fixtures {

    static func empty() -> GridState {
        GridState()
    }

    /// Single horizontal 4-in-a-row at row 5, cols 1–4.
    static func single4H() -> GridState {
        var g = GridState()
        for c in 1...4 { g.set(.red, at: c, row: 5) }
        return g
    }

    /// Single vertical 4-in-a-row at col 3, rows 2–5.
    static func single4V() -> GridState {
        var g = GridState()
        for r in 2...5 { g.set(.blue, at: 3, row: r) }
        return g
    }

    /// Top-out: row 0 has a piece (spawn blocked).
    static func topOut() -> GridState {
        var g = GridState()
        g.set(.red, at: 3, row: 0)
        g.set(.red, at: 4, row: 0)
        return g
    }

    /// Disconnected half: horizontal pair, clearing one leaves orphan.
    static func disconnectedHalf() -> GridState {
        var g = GridState()
        g.set(.red, at: 2, row: 10)
        g.set(.red, at: 3, row: 10)
        g.set(.blue, at: 4, row: 10)
        g.set(.blue, at: 5, row: 10)
        return g
    }

    /// Simultaneous clear: two horizontal matches same row.
    static func simultaneousClear() -> GridState {
        var g = GridState()
        for c in 0...3 { g.set(.red, at: c, row: 5) }
        for c in 4...7 { g.set(.blue, at: c, row: 5) }
        return g
    }
}
