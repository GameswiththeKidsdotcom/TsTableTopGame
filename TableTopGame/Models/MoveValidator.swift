import Foundation

/// Validates capsule moves and rotations. Handles wall kick.
enum MoveValidator {

    /// Returns the two (col, row) positions for a capsule with pivot at (col, row).
    static func segments(col: Int, row: Int, orientation: CapsuleOrientation) -> [(col: Int, row: Int)] {
        switch orientation {
        case .up:    return [(col, row), (col, row - 1)]
        case .down:  return [(col, row), (col, row + 1)]
        case .left:  return [(col, row), (col - 1, row)]
        case .right: return [(col, row), (col + 1, row)]
        }
    }

    /// True if both segments are in bounds and not occupied.
    static func canPlace(
        col: Int, row: Int, orientation: CapsuleOrientation,
        in gridState: GridState
    ) -> Bool {
        let segs = segments(col: col, row: row, orientation: orientation)
        for s in segs {
            guard Grid.isValid(col: s.col, row: s.row) else { return false }
            guard !gridState.isOccupied(col: s.col, row: s.row) else { return false }
        }
        return true
    }

    /// True if capsule can move left.
    static func canMoveLeft(
        col: Int, row: Int, orientation: CapsuleOrientation,
        in gridState: GridState
    ) -> Bool {
        canPlace(col: col - 1, row: row, orientation: orientation, in: gridState)
    }

    /// True if capsule can move right.
    static func canMoveRight(
        col: Int, row: Int, orientation: CapsuleOrientation,
        in gridState: GridState
    ) -> Bool {
        canPlace(col: col + 1, row: row, orientation: orientation, in: gridState)
    }

    /// True if capsule can move down one row.
    static func canMoveDown(
        col: Int, row: Int, orientation: CapsuleOrientation,
        in gridState: GridState
    ) -> Bool {
        canPlace(col: col, row: row + 1, orientation: orientation, in: gridState)
    }

    /// Next orientation CW: up→right→down→left→up.
    static func rotateCW(_ o: CapsuleOrientation) -> CapsuleOrientation {
        switch o {
        case .up: return .right
        case .right: return .down
        case .down: return .left
        case .left: return .up
        }
    }

    /// Next orientation CCW.
    static func rotateCCW(_ o: CapsuleOrientation) -> CapsuleOrientation {
        switch o {
        case .up: return .left
        case .left: return .down
        case .down: return .right
        case .right: return .up
        }
    }

    /// All valid (col, orientation) placements at spawn row 0. Used by AI to enumerate moves.
    static func validPlacementsAtSpawn(in gridState: GridState) -> [(col: Int, orientation: CapsuleOrientation)] {
        var result: [(col: Int, orientation: CapsuleOrientation)] = []
        for col in 0..<Grid.columns {
            for orientation in CapsuleOrientation.allCases {
                if canPlace(col: col, row: 0, orientation: orientation, in: gridState) {
                    result.append((col, orientation))
                }
            }
        }
        return result
    }

    /// Wall kick: if rotation blocked, try shifting left 1. Returns (newCol, newOrientation) or nil if no valid placement.
    static func rotateWithWallKick(
        col: Int, row: Int, orientation: CapsuleOrientation,
        clockwise: Bool, in gridState: GridState
    ) -> (col: Int, orientation: CapsuleOrientation)? {
        let next = clockwise ? rotateCW(orientation) : rotateCCW(orientation)
        if canPlace(col: col, row: row, orientation: next, in: gridState) {
            return (col, next)
        }
        if canPlace(col: col - 1, row: row, orientation: next, in: gridState) {
            return (col - 1, next)
        }
        if canPlace(col: col + 1, row: row, orientation: next, in: gridState) {
            return (col + 1, next)
        }
        return nil
    }
}
