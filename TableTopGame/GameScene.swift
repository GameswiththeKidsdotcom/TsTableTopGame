import SpriteKit

/// Game scene with 8×16 grid. Renders grid, viruses, and playable capsule.
class GameScene: SKScene {

    private let gridColumns = Grid.columns
    private let gridRows = Grid.rows
    private var cellSize: CGFloat = 0
    private let gridNode = SKNode()
    private var gridState = GridState()

    // Active capsule (pivot position)
    private var capsuleCol: Int = 3
    private var capsuleRow: Int = 0
    private var capsuleOrientation: CapsuleOrientation = .right
    private var capsuleLeftColor: PillColor = .red
    private var capsuleRightColor: PillColor = .blue

    private var dropAccumulator: TimeInterval = 0
    private let dropInterval: TimeInterval = 0.5
    private var isLocked = false
    private var inputDisabled = false

    override func didMove(to view: SKView) {
        backgroundColor = .black
        addChild(gridNode)
        let viruses = makeDemoViruses()
        gridState.addViruses(viruses)
        spawnCapsule()
        layoutGrid()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutGrid()
    }

    override func update(_ currentTime: TimeInterval) {
        guard !inputDisabled, !isLocked else { return }
        dropAccumulator += 0.016
        if dropAccumulator >= dropInterval {
            dropAccumulator = 0
            tryMoveDown()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !inputDisabled else { return }
        let loc = touch.location(in: self)
        let w = size.width
        let h = size.height

        if isLocked { return }

        if loc.x < w * 0.25 {
            tryMoveLeft()
        } else if loc.x > w * 0.75 {
            tryMoveRight()
        } else if loc.y > h * 0.8 {
            hardDrop()
        } else {
            tryRotate()
        }
    }

    private func makeDemoViruses() -> [Virus] {
        [
            Virus(col: 1, row: 2, color: .red),
            Virus(col: 3, row: 4, color: .blue),
            Virus(col: 5, row: 6, color: .yellow),
            Virus(col: 2, row: 8, color: .yellow),
            Virus(col: 4, row: 10, color: .red),
            Virus(col: 6, row: 12, color: .blue),
        ]
    }

    private func spawnCapsule() {
        capsuleCol = 3
        capsuleRow = 0
        capsuleOrientation = .right
        capsuleLeftColor = PillColor.allCases.randomElement() ?? .red
        capsuleRightColor = PillColor.allCases.randomElement() ?? .blue
        isLocked = false
        if !MoveValidator.canPlace(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: gridState) {
            // Game over - spawn blocked
            inputDisabled = true
        }
    }

    private func tryMoveLeft() {
        guard MoveValidator.canMoveLeft(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: gridState) else { return }
        capsuleCol -= 1
        layoutGrid()
    }

    private func tryMoveRight() {
        guard MoveValidator.canMoveRight(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: gridState) else { return }
        capsuleCol += 1
        layoutGrid()
    }

    private func tryMoveDown() {
        guard MoveValidator.canMoveDown(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: gridState) else {
            lockCapsule()
            return
        }
        capsuleRow += 1
        layoutGrid()
    }

    private func tryRotate() {
        guard let result = MoveValidator.rotateWithWallKick(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, clockwise: true, in: gridState) else { return }
        capsuleCol = result.col
        capsuleOrientation = result.orientation
        layoutGrid()
    }

    private func hardDrop() {
        while MoveValidator.canMoveDown(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: gridState) {
            capsuleRow += 1
        }
        lockCapsule()
    }

    private func lockCapsule() {
        isLocked = true
        let segs = MoveValidator.segments(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation)
        gridState.set(capsuleLeftColor, at: segs[0].col, row: segs[0].row)
        gridState.set(capsuleRightColor, at: segs[1].col, row: segs[1].row)
        GravityEngine.resolve(gridState: &gridState)
        spawnCapsule()
        layoutGrid()
    }

    private func skColor(for pillColor: PillColor) -> SKColor {
        switch pillColor {
        case .red: return .red
        case .blue: return .blue
        case .yellow: return .yellow
        }
    }

    private func isCapsuleSegment(col: Int, row: Int) -> PillColor? {
        guard !isLocked else { return nil }
        let segs = MoveValidator.segments(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation)
        if segs[0].col == col && segs[0].row == row { return capsuleLeftColor }
        if segs[1].col == col && segs[1].row == row { return capsuleRightColor }
        return nil
    }

    private func layoutGrid() {
        gridNode.removeAllChildren()
        guard gridColumns > 0, gridRows > 0 else { return }

        let w = size.width
        let h = size.height
        let cellW = w / CGFloat(gridColumns)
        let cellH = h / CGFloat(gridRows)
        cellSize = min(cellW, cellH)
        let gridPixelW = cellSize * CGFloat(gridColumns)
        let gridPixelH = cellSize * CGFloat(gridRows)
        let offsetX = (w - gridPixelW) / 2
        let offsetY = (h - gridPixelH) / 2

        for row in 0..<gridRows {
            for col in 0..<gridColumns {
                let rect = SKShapeNode(rectOf: CGSize(width: cellSize - 1, height: cellSize - 1))
                rect.strokeColor = .darkGray
                if let capColor = isCapsuleSegment(col: col, row: row) {
                    rect.fillColor = skColor(for: capColor)
                } else if let gridColor = gridState.color(at: col, row: row) {
                    rect.fillColor = skColor(for: gridColor)
                } else {
                    rect.fillColor = .black
                }
                rect.position = CGPoint(
                    x: offsetX + cellSize * (CGFloat(col) + 0.5),
                    y: offsetY + cellSize * (CGFloat(row) + 0.5)
                )
                rect.zPosition = 0
                gridNode.addChild(rect)
            }
        }
    }
}
