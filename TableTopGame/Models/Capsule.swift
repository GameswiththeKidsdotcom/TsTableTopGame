import Foundation

/// Capsule orientation. Bottom-left pivot (first segment fixed).
enum CapsuleOrientation: Int, CaseIterable, Codable {
    case up = 0      // second segment above first
    case right = 1   // second segment right of first
    case down = 2    // second segment below first
    case left = 3    // second segment left of first
}

/// A two-segment capsule. SPEC: 4 orientations, bottom-left pivot.
struct Capsule {
    let col: Int
    let row: Int
    let orientation: CapsuleOrientation
    let leftColor: PillColor
    let rightColor: PillColor

    init(col: Int, row: Int, orientation: CapsuleOrientation, leftColor: PillColor, rightColor: PillColor) {
        self.col = col
        self.row = row
        self.orientation = orientation
        self.leftColor = leftColor
        self.rightColor = rightColor
    }
}
