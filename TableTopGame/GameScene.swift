import SpriteKit

/// Game scene with empty 8×16 grid. Renders grid cells.
class GameScene: SKScene {

    private let gridColumns = Grid.columns
    private let gridRows = Grid.rows
    private var cellSize: CGFloat = 0
    private let gridNode = SKNode()

    override func didMove(to view: SKView) {
        backgroundColor = .black
        addChild(gridNode)
        layoutGrid()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutGrid()
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
                rect.fillColor = .black
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
