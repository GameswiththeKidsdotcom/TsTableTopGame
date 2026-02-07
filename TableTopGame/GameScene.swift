import SpriteKit

/// Game scene with 8×16 grid. Renders current player's grid, viruses, and playable capsule. C6: turn flow and win/elimination via GameState.
class GameScene: SKScene {

    private let gridColumns = Grid.columns
    private let gridRows = Grid.rows
    private var cellSize: CGFloat = 0
    private let gridNode = SKNode()

    /// C6: Single source of truth for 2-player turn flow, win/elimination, virus init, capsule queue.
    private var gameState: GameState!

    private var dropAccumulator: TimeInterval = 0
    private let dropInterval: TimeInterval = 0.5

    override func didMove(to view: SKView) {
        backgroundColor = .black
        addChild(gridNode)
        gameState = GameState(level: 0)
        layoutGrid()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard gameState != nil else { return }
        layoutGrid()
    }

    override func update(_ currentTime: TimeInterval) {
        guard let gameState = gameState else { return }
        guard gameState.canAcceptInput else { return }
        dropAccumulator += 0.016
        if dropAccumulator >= dropInterval {
            dropAccumulator = 0
            gameState.tryMoveDown()
            layoutGrid()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameState = gameState, let touch = touches.first, gameState.canAcceptInput else { return }
        let loc = touch.location(in: self)
        let w = size.width
        let h = size.height

        if loc.x < w * 0.25 {
            gameState.tryMoveLeft()
        } else if loc.x > w * 0.75 {
            gameState.tryMoveRight()
        } else if loc.y > h * 0.8 {
            gameState.hardDrop()
        } else {
            gameState.tryRotate()
        }
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
        guard let gameState = gameState, !gameState.isCapsuleLocked else { return nil }
        let segs = MoveValidator.segments(col: gameState.capsuleCol, row: gameState.capsuleRow, orientation: gameState.capsuleOrientation)
        if segs[0].col == col && segs[0].row == row { return gameState.capsuleLeftColor }
        if segs[1].col == col && segs[1].row == row { return gameState.capsuleRightColor }
        return nil
    }

    private func layoutGrid() {
        guard let gameState = gameState else { return }
        gridNode.removeAllChildren()
        guard gridColumns > 0, gridRows > 0 else { return }

        let gridState = gameState.currentGridState()
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
