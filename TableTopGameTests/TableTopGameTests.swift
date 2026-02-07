import XCTest
@testable import TableTopGame

final class TableTopGameTests: XCTestCase {

    func testPillColorCases() {
        XCTAssertEqual(PillColor.allCases.count, 3)
        XCTAssertTrue(PillColor.allCases.contains(.red))
        XCTAssertTrue(PillColor.allCases.contains(.blue))
        XCTAssertTrue(PillColor.allCases.contains(.yellow))
    }

    func testGridDimensions() {
        XCTAssertEqual(Grid.columns, 8)
        XCTAssertEqual(Grid.rows, 16)
    }

    func testGridIsValid() {
        XCTAssertTrue(Grid.isValid(col: 0, row: 0))
        XCTAssertTrue(Grid.isValid(col: 7, row: 15))
        XCTAssertFalse(Grid.isValid(col: -1, row: 0))
        XCTAssertFalse(Grid.isValid(col: 8, row: 0))
        XCTAssertFalse(Grid.isValid(col: 0, row: 16))
    }

    func testCapsuleOrientations() {
        XCTAssertEqual(CapsuleOrientation.allCases.count, 4)
    }

    func testCapsuleInit() {
        let cap = Capsule(col: 3, row: 0, orientation: .up, leftColor: .red, rightColor: .blue)
        XCTAssertEqual(cap.col, 3)
        XCTAssertEqual(cap.row, 0)
        XCTAssertEqual(cap.orientation, .up)
        XCTAssertEqual(cap.leftColor, .red)
        XCTAssertEqual(cap.rightColor, .blue)
    }

    func testVirusInit() {
        let v = Virus(col: 2, row: 5, color: .yellow)
        XCTAssertEqual(v.col, 2)
        XCTAssertEqual(v.row, 5)
        XCTAssertEqual(v.color, .yellow)
    }

    func testPlayerInit() {
        let p = Player(id: 1)
        XCTAssertEqual(p.id, 1)
        XCTAssertEqual(p.name, "Player 1")
        let p2 = Player(id: 0, name: "Human")
        XCTAssertEqual(p2.name, "Human")
    }

    // MARK: - MoveValidator

    func testMoveValidatorSegments() {
        let segsRight = MoveValidator.segments(col: 3, row: 0, orientation: .right)
        XCTAssertEqual(segsRight.count, 2)
        XCTAssertTrue(segsRight.contains { $0.col == 3 && $0.row == 0 })
        XCTAssertTrue(segsRight.contains { $0.col == 4 && $0.row == 0 })

        let segsDown = MoveValidator.segments(col: 3, row: 1, orientation: .down)
        XCTAssertTrue(segsDown.contains { $0.col == 3 && $0.row == 1 })
        XCTAssertTrue(segsDown.contains { $0.col == 3 && $0.row == 2 })
    }

    func testMoveValidatorCanPlaceEmpty() {
        var g = GridState()
        XCTAssertTrue(MoveValidator.canPlace(col: 3, row: 0, orientation: .right, in: g))
    }

    func testMoveValidatorRejectsOOB() {
        var g = GridState()
        XCTAssertFalse(MoveValidator.canPlace(col: 7, row: 0, orientation: .right, in: g))
        XCTAssertFalse(MoveValidator.canPlace(col: -1, row: 0, orientation: .left, in: g))
    }

    func testMoveValidatorRejectsBlocked() {
        var g = GridState()
        g.set(.red, at: 4, row: 0)
        XCTAssertFalse(MoveValidator.canPlace(col: 3, row: 0, orientation: .right, in: g))
    }

    func testMoveValidatorRotation() {
        XCTAssertEqual(MoveValidator.rotateCW(.up), .right)
        XCTAssertEqual(MoveValidator.rotateCW(.right), .down)
        XCTAssertEqual(MoveValidator.rotateCCW(.up), .left)
    }

    func testMoveValidatorWallKick() {
        var g = GridState()
        g.set(.red, at: 7, row: 5)  // Block right; vertical at (6,5) rotating to horizontal kicks left
        let result = MoveValidator.rotateWithWallKick(col: 6, row: 5, orientation: .up, clockwise: true, in: g)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.col, 5)
        XCTAssertEqual(result?.orientation, .right)
    }

    // MARK: - MatchResolver

    func testMatchResolverSingle4H() {
        let g = Fixtures.single4H()
        let matches = MatchResolver.findMatches(in: g)
        XCTAssertEqual(matches.count, 4)
    }

    func testMatchResolverSingle4V() {
        let g = Fixtures.single4V()
        let matches = MatchResolver.findMatches(in: g)
        XCTAssertEqual(matches.count, 4)
    }

    func testMatchResolverEmpty() {
        let g = Fixtures.empty()
        let matches = MatchResolver.findMatches(in: g)
        XCTAssertTrue(matches.isEmpty)
    }

    func testMatchResolverSimultaneousClear() {
        let g = Fixtures.simultaneousClear()
        let matches = MatchResolver.findMatches(in: g)
        XCTAssertEqual(matches.count, 8)
    }

    // MARK: - GravityEngine

    func testGravityEngineApply() {
        var g = GridState()
        g.set(.red, at: 3, row: 0)
        let changed = GravityEngine.apply(to: &g)
        XCTAssertTrue(changed)
        XCTAssertNil(g.color(at: 3, row: 0))
        XCTAssertEqual(g.color(at: 3, row: 1), .red)
    }

    func testGravityEngineResolve() {
        var g = Fixtures.single4H()
        GravityEngine.resolve(gridState: &g)
        XCTAssertTrue(g.occupied.isEmpty)
    }
}
