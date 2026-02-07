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
}
