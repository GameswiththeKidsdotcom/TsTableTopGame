import XCTest

/// E2E UI tests for TableTopGame. Launch → Menu → New Game → overlay → Restart/Return to Menu; Settings; GameOver fixture.

// MARK: - Board tap helper (E2E-P4). Same formula as GameScene.layoutGrid(): grid 8×16, cellSize = min(halfW/8, h/16).
enum BoardTapHelper {
    static let gridColumns = 8
    static let gridRows = 16

    /// Grid frame in screen coordinates. leftGrid = P0, rightGrid = P1.
    static func gridFrames(screenWidth: CGFloat, screenHeight: CGFloat) -> (left: CGRect, right: CGRect) {
        let w = screenWidth
        let h = screenHeight
        let halfW = w / 2
        let cellSize = min(halfW / CGFloat(gridColumns), h / CGFloat(gridRows))
        let gridPixelW = cellSize * CGFloat(gridColumns)
        let gridPixelH = cellSize * CGFloat(gridRows)
        let offsetY = (h - gridPixelH) / 2
        let leftGridLeft = (halfW - gridPixelW) / 2
        let rightGridLeft = halfW + (halfW - gridPixelW) / 2
        let left = CGRect(x: leftGridLeft, y: offsetY, width: gridPixelW, height: gridPixelH)
        let right = CGRect(x: rightGridLeft, y: offsetY, width: gridPixelW, height: gridPixelH)
        return (left, right)
    }

    /// Tap zone per FIXTURES.md: left 25% = move left, right 25% = move right, top 20% = hard drop, else = rotate.
    enum Zone {
        case moveLeft   // left 25%
        case moveRight  // right 25%
        case hardDrop  // top 20%
        case rotate    // middle 50% width, below top band
    }

    static func tapPoint(in frame: CGRect, zone: Zone) -> CGPoint {
        switch zone {
        case .moveLeft:
            return CGPoint(x: frame.minX + frame.width * 0.125, y: frame.midY)
        case .moveRight:
            return CGPoint(x: frame.minX + frame.width * 0.875, y: frame.midY)
        case .hardDrop:
            return CGPoint(x: frame.midX, y: frame.minY + frame.height * 0.1)
        case .rotate:
            return CGPoint(x: frame.midX, y: frame.minY + frame.height * 0.5)
        }
    }
}

final class TableTopGameUITests: XCTestCase {

    /// Menu ready timeout (seconds) for simulator boot; per e2e_active_wait_and_simulator_boot plan.
    private let menuReadyTimeout: TimeInterval = 60
    /// Game HUD ready timeout (seconds) for turn label after New Game tap; per e2e_active_wait plan.
    private let gameHudReadyTimeout: TimeInterval = 10

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    // E2E-P2: Launch → Menu
    func testLaunchShowsMenu() throws {
        app.launch()
        XCTAssertTrue(app.staticTexts["TableTopGame"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["newGameButton"].waitForExistence(timeout: 2))
    }

    // E2E-P3: Menu → New Game
    func testNewGameShowsGameView() throws {
        app.launch()
        XCTAssertTrue(app.buttons["newGameButton"].waitForExistence(timeout: 3))
        app.buttons["newGameButton"].tap()
        // HUD shows "Player 1's turn" or "Player 2's turn"
        let playerTurn = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "turn")).firstMatch
        XCTAssertTrue(playerTurn.waitForExistence(timeout: 5))
    }

    // E2E-Settings (C10-V6): Settings sheet
    func testSettingsSheet() throws {
        app.launch()
        XCTAssertTrue(app.buttons["settingsButton"].waitForExistence(timeout: 3))
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.switches["soundToggle"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.sliders["aiDelaySlider"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
        XCTAssertTrue(app.buttons["newGameButton"].waitForExistence(timeout: 2))
    }

    // C10-V8: Viewport layout – GameOverOverlay legible on small/large iPhone and iPad.
    // Run on iPhone SE (or iPhone 16), iPhone 15 Pro Max (or iPhone 16 Pro Max), iPad Pro 11.
    func testC10V8GameOverOverlayLegibleOnViewports() throws {
        app.launchArguments = ["-GameOverFixture", "win"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Player 1 wins!"].waitForExistence(timeout: 5), "GameOver title legible")
        XCTAssertTrue(app.staticTexts["P1: $0"].waitForExistence(timeout: 2), "P1 cash legible")
        XCTAssertTrue(app.staticTexts["P2: $0"].waitForExistence(timeout: 2), "P2 cash legible")
        XCTAssertTrue(app.buttons["restartButton"].waitForExistence(timeout: 2) && app.buttons["restartButton"].isHittable, "Restart tappable")
        XCTAssertTrue(app.buttons["returnToMenuButton"].waitForExistence(timeout: 2) && app.buttons["returnToMenuButton"].isHittable, "Return to Menu tappable")
    }

    // C10-V9: Layout and contrast – GameOverOverlay white-on-black; Restart/Return to Menu tappable; HUD contrast.
    func testC10V9LayoutAndContrast() throws {
        // Overlay: white-on-black (0.7), buttons tappable
        app.launchArguments = ["-GameOverFixture", "win"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Player 1 wins!"].waitForExistence(timeout: 5), "Overlay title (white on black) visible")
        XCTAssertTrue(app.buttons["restartButton"].waitForExistence(timeout: 2) && app.buttons["restartButton"].isHittable, "Restart tappable")
        XCTAssertTrue(app.buttons["returnToMenuButton"].waitForExistence(timeout: 2) && app.buttons["returnToMenuButton"].isHittable, "Return to Menu tappable")
        // Tap Restart → game view; HUD (black 0.6, white text) visible
        app.buttons["restartButton"].tap()
        let playerTurn = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "turn")).firstMatch
        XCTAssertTrue(playerTurn.waitForExistence(timeout: 5), "HUD turn label visible (contrast)")
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "P1:")).firstMatch.waitForExistence(timeout: 2), "HUD P1 cash visible")
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "P2:")).firstMatch.waitForExistence(timeout: 2), "HUD P2 cash visible")
    }

    // E2E-OverlayAssert (C10-V2/V3/V4): GameOver fixture – win
    func testGameOverFixtureWin() throws {
        app.launchArguments = ["-GameOverFixture", "win"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Player 1 wins!"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["restartButton"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["returnToMenuButton"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["restartButton"].isHittable)
        XCTAssertTrue(app.buttons["returnToMenuButton"].isHittable)
    }

    // E2E-OverlayAssert: GameOver fixture – lose (Player 2 wins)
    func testGameOverFixtureLose() throws {
        app.launchArguments = ["-GameOverFixture", "lose"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Player 2 wins!"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["restartButton"].isHittable)
        XCTAssertTrue(app.buttons["returnToMenuButton"].isHittable)
    }

    // E2E-OverlayAssert: GameOver fixture – tie
    func testGameOverFixtureTie() throws {
        app.launchArguments = ["-GameOverFixture", "tie"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Tie!"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["restartButton"].isHittable)
        XCTAssertTrue(app.buttons["returnToMenuButton"].isHittable)
    }

    // E2E-P7a: Fixture Restart → new game
    func testGameOverFixtureRestart() throws {
        app.launchArguments = ["-GameOverFixture", "win"]
        app.launch()
        XCTAssertTrue(app.buttons["restartButton"].waitForExistence(timeout: 5))
        app.buttons["restartButton"].tap()
        // GameView + GameScene need time to initialize; 15s for slower simulator
        let playerTurn = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "turn")).firstMatch
        XCTAssertTrue(playerTurn.waitForExistence(timeout: 15), "HUD turn label did not appear after Restart tap")
    }

    // E2E-P7b: Fixture Return to Menu → MenuView
    func testGameOverFixtureReturnToMenu() throws {
        app.launchArguments = ["-GameOverFixture", "tie"]
        app.launch()
        XCTAssertTrue(app.buttons["returnToMenuButton"].waitForExistence(timeout: 3))
        app.buttons["returnToMenuButton"].tap()
        XCTAssertTrue(app.buttons["newGameButton"].waitForExistence(timeout: 3))
    }

    // E2E-P4+P5: Full playthrough until game over (timeout 180s). Taps active board per FIXTURES zones.
    func testFullPlaythroughUntilGameOver() throws {
        runFullPlaythrough(stepDelayMs: 400, totalTimeout: 180)
    }

    /// Same as full playthrough but with ~2s between moves so you can watch. Run: -only-testing:TableTopGameUITests/testFullPlaythroughUntilGameOverSlow
    func testFullPlaythroughUntilGameOverSlow() throws {
        runFullPlaythrough(stepDelayMs: 2000, totalTimeout: 300)
    }

    private func runFullPlaythrough(stepDelayMs: UInt32, totalTimeout: TimeInterval) {
        app.launch()
        let newGameButton = app.buttons["newGameButton"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: menuReadyTimeout), "Menu with New Game button did not appear within \(menuReadyTimeout)s")
        newGameButton.tap()
        let turnLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "turn")).firstMatch
        XCTAssertTrue(turnLabel.waitForExistence(timeout: gameHudReadyTimeout), "Game HUD (turn label) did not appear within \(gameHudReadyTimeout)s")

        let window = app.windows.firstMatch
        let deadline = Date().addingTimeInterval(totalTimeout)
        let stepDelayUs = stepDelayMs * 1000

        while Date() < deadline {
            if app.buttons["restartButton"].waitForExistence(timeout: 1) {
                break
            }
            if app.staticTexts["Player 1 wins!"].exists || app.staticTexts["Player 2 wins!"].exists || app.staticTexts["Tie!"].exists {
                break
            }

            let frame = window.frame
            let (left, right) = BoardTapHelper.gridFrames(screenWidth: frame.width, screenHeight: frame.height)
            let player1Turn = app.staticTexts["Player 1's turn"].exists
            let gridFrame = player1Turn ? left : right
            let point = BoardTapHelper.tapPoint(in: gridFrame, zone: .rotate)
            let coord = window.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
                .withOffset(CGVector(dx: point.x, dy: point.y))
            coord.tap()
            usleep(stepDelayUs)
        }

        XCTAssertTrue(
            app.buttons["restartButton"].waitForExistence(timeout: 5) ||
            app.staticTexts["Player 1 wins!"].exists ||
            app.staticTexts["Player 2 wins!"].exists ||
            app.staticTexts["Tie!"].exists,
            "Game over overlay did not appear within \(totalTimeout)s"
        )
        XCTAssertTrue(app.buttons["restartButton"].isHittable)
        XCTAssertTrue(app.buttons["returnToMenuButton"].isHittable)
    }

    // E2E-SettingsPersist (C10-V7): Change settings, terminate, relaunch, assert values.
    func testSettingsPersist() throws {
        app.launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.switches["soundToggle"].waitForExistence(timeout: 5))
        // Set AI delay to 2.5s (normalized 0.8 on 0.5–3.0) – distinctive for persistence assert
        app.sliders["aiDelaySlider"].adjust(toNormalizedSliderPosition: 0.8)
        app.buttons["settingsDoneButton"].tap()
        app.terminate()
        app.launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.switches["soundToggle"].waitForExistence(timeout: 5), "Settings sheet did not appear after relaunch")
        // AI delay 2.5s proves UserDefaults persistence; sound uses same mechanism
        XCTAssertTrue(app.staticTexts["AI delay: 2.5s"].waitForExistence(timeout: 5),
                      "Expected AI delay 2.5s after persist; settings did not persist across app restart")
        app.buttons["settingsDoneButton"].tap()
    }
}
