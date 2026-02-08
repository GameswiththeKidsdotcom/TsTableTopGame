import SpriteKit

/// Game scene with 8×16 grid. Renders current player's grid, viruses, and playable capsule. C6: turn flow and win/elimination via GameState. C8: two grids side-by-side, avatars, highlight, HUD data.
class GameScene: SKScene {

    private let gridColumns = Grid.columns
    private let gridRows = Grid.rows
    private var cellSize: CGFloat = 0
    /// C8: Left half = P0, right half = P1.
    private let leftGridNode = SKNode()
    private let rightGridNode = SKNode()
    /// C8: Avatars (P0 blue, P1 orange) left of P0 grid, right of P1 grid.
    private let leftAvatarNode = SKShapeNode(rectOf: CGSize(width: 1, height: 1))
    private let rightAvatarNode = SKShapeNode(rectOf: CGSize(width: 1, height: 1))
    /// C8: Highlight border on active player's grid.
    private let leftHighlightNode = SKShapeNode(rectOf: CGSize(width: 1, height: 1))
    private let rightHighlightNode = SKShapeNode(rectOf: CGSize(width: 1, height: 1))

    /// C6: Single source of truth for 2-player turn flow, win/elimination, virus init, capsule queue.
    private var gameState: GameState!

    /// C8: Grid frames in scene coords for touch scoping (left = P0, right = P1).
    private var leftGridFrame: CGRect = .zero
    private var rightGridFrame: CGRect = .zero

    /// C8: Optional display hook for SwiftUI HUD (turn, cash, next capsule).
    weak var stateDisplay: GameStateDisplay?

    /// C9: AI for opponent (Player 1). When non-nil, AI moves automatically after delay.
    var aiController: AIController?

    private var dropAccumulator: TimeInterval = 0
    private let dropInterval: TimeInterval = 0.5
    private var aiDelayAccumulator: TimeInterval = 0
    private let aiDelay: TimeInterval = 1.5

    override func didMove(to view: SKView) {
        backgroundColor = .black
        addChild(leftGridNode)
        addChild(rightGridNode)
        leftAvatarNode.fillColor = .systemBlue
        leftAvatarNode.strokeColor = .clear
        rightAvatarNode.fillColor = .systemOrange
        rightAvatarNode.strokeColor = .clear
        addChild(leftAvatarNode)
        addChild(rightAvatarNode)
        leftHighlightNode.fillColor = .clear
        leftHighlightNode.strokeColor = .systemYellow
        leftHighlightNode.lineWidth = 3
        rightHighlightNode.fillColor = .clear
        rightHighlightNode.strokeColor = .systemYellow
        rightHighlightNode.lineWidth = 3
        addChild(leftHighlightNode)
        addChild(rightHighlightNode)
        gameState = GameState(level: 0)
        aiController = GreedyAI()
        layoutGrid()
        pushStateToDisplay()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard gameState != nil else { return }
        layoutGrid()
    }

    override func update(_ currentTime: TimeInterval) {
        guard let gameState = gameState else { return }
        guard gameState.canAcceptInput else { return }

        let dt: TimeInterval = 0.016

        if gameState.currentPlayerIndex == 1, let ai = aiController {
            aiDelayAccumulator += dt
            if aiDelayAccumulator >= aiDelay {
                aiDelayAccumulator = 0
                if let snapshot = gameState.aiSnapshotForCurrentPlayer(),
                   let move = ai.move(for: snapshot) {
                    gameState.applyAIMove(col: move.col, orientation: move.orientation)
                    layoutGrid()
                }
            }
            return
        }

        dropAccumulator += dt
        if dropAccumulator >= dropInterval {
            dropAccumulator = 0
            gameState.tryMoveDown()
            layoutGrid()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameState = gameState, let touch = touches.first, gameState.canAcceptInput else { return }
        let loc = touch.location(in: self)
        let activeFrame = gameState.currentPlayerIndex == 0 ? leftGridFrame : rightGridFrame
        guard activeFrame.contains(loc) else { return }

        let relX = (loc.x - activeFrame.minX) / activeFrame.width
        let relY = (loc.y - activeFrame.minY) / activeFrame.height

        if relX < 0.25 {
            gameState.tryMoveLeft()
        } else if relX > 0.75 {
            gameState.tryMoveRight()
        } else if relY > 0.8 {
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

    /// Capsule segment only for current player's grid.
    private func isCapsuleSegment(col: Int, row: Int, playerIndex: Int) -> PillColor? {
        guard let gameState = gameState, gameState.currentPlayerIndex == playerIndex, !gameState.isCapsuleLocked else { return nil }
        let segs = MoveValidator.segments(col: gameState.capsuleCol, row: gameState.capsuleRow, orientation: gameState.capsuleOrientation)
        if segs[0].col == col && segs[0].row == row { return gameState.capsuleLeftColor }
        if segs[1].col == col && segs[1].row == row { return gameState.capsuleRightColor }
        return nil
    }

    /// C8: Side-by-side layout. Left half = P0, right half = P1. Per-grid cellSize = min((w/2)/8, h/16).
    private func layoutGrid() {
        guard let gameState = gameState else { return }
        leftGridNode.removeAllChildren()
        rightGridNode.removeAllChildren()
        guard gridColumns > 0, gridRows > 0 else { return }

        let w = size.width
        let h = size.height
        let halfW = w / 2
        // Size cells so each grid fits in its half (no overlap). On very small screens cells may be < 32pt.
        cellSize = min(halfW / CGFloat(gridColumns), h / CGFloat(gridRows))
        let gridPixelW = cellSize * CGFloat(gridColumns)
        let gridPixelH = cellSize * CGFloat(gridRows)
        let offsetY = (h - gridPixelH) / 2

        let leftGridLeft = (halfW - gridPixelW) / 2
        let rightGridLeft = halfW + (halfW - gridPixelW) / 2
        leftGridFrame = CGRect(x: leftGridLeft, y: offsetY, width: gridPixelW, height: gridPixelH)
        rightGridFrame = CGRect(x: rightGridLeft, y: offsetY, width: gridPixelW, height: gridPixelH)

        for playerIndex in 0..<2 {
            let gridState = gameState.gridState(forPlayer: playerIndex)
            let offsetX: CGFloat = playerIndex == 0 ? leftGridLeft : rightGridLeft
            let parent = playerIndex == 0 ? leftGridNode : rightGridNode

            for row in 0..<gridRows {
                for col in 0..<gridColumns {
                    let rect = SKShapeNode(rectOf: CGSize(width: cellSize - 1, height: cellSize - 1))
                    rect.strokeColor = .darkGray
                    if let capColor = isCapsuleSegment(col: col, row: row, playerIndex: playerIndex) {
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
                    parent.addChild(rect)
                }
            }
        }

        // C8: Position avatars (left of P0 grid, right of P1 grid) and size by cellSize.
        let avatarSize = cellSize * 2
        let padding: CGFloat = 4
        let rightGridRight = rightGridLeft + gridPixelW
        let centerY = offsetY + gridPixelH / 2
        leftAvatarNode.position = CGPoint(x: leftGridLeft - padding - avatarSize / 2, y: centerY)
        leftAvatarNode.path = CGPath(rect: CGRect(x: -avatarSize / 2, y: -avatarSize / 2, width: avatarSize, height: avatarSize), transform: nil)
        rightAvatarNode.position = CGPoint(x: rightGridRight + padding + avatarSize / 2, y: centerY)
        rightAvatarNode.path = CGPath(rect: CGRect(x: -avatarSize / 2, y: -avatarSize / 2, width: avatarSize, height: avatarSize), transform: nil)
        leftAvatarNode.zPosition = 1
        rightAvatarNode.zPosition = 1

        // C8: Active player highlight (border around current grid).
        leftHighlightNode.position = CGPoint(x: leftGridLeft + gridPixelW / 2, y: centerY)
        leftHighlightNode.path = CGPath(rect: CGRect(x: -gridPixelW / 2 - 2, y: -gridPixelH / 2 - 2, width: gridPixelW + 4, height: gridPixelH + 4), transform: nil)
        rightHighlightNode.position = CGPoint(x: rightGridLeft + gridPixelW / 2, y: centerY)
        rightHighlightNode.path = CGPath(rect: CGRect(x: -gridPixelW / 2 - 2, y: -gridPixelH / 2 - 2, width: gridPixelW + 4, height: gridPixelH + 4), transform: nil)
        leftHighlightNode.zPosition = 2
        rightHighlightNode.zPosition = 2
        leftHighlightNode.isHidden = gameState.currentPlayerIndex != 0
        rightHighlightNode.isHidden = gameState.currentPlayerIndex != 1

        pushStateToDisplay()
    }

    private func pushStateToDisplay() {
        guard let gameState = gameState else { return }
        stateDisplay?.update(
            currentPlayerIndex: gameState.currentPlayerIndex,
            cash: gameState.cash,
            nextCapsule: gameState.nextCapsuleInQueue(),
            phase: gameState.phase
        )
    }
}
