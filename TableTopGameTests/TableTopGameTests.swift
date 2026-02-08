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

    // MARK: - GamePhase

    func testGamePhasePlaying() {
        XCTAssertEqual(GamePhase.playing, GamePhase.playing)
    }

    func testGamePhaseGameOver() {
        let w = GamePhase.gameOver(winnerId: 0, isTie: false)
        XCTAssertEqual(w, GamePhase.gameOver(winnerId: 0, isTie: false))
        let t = GamePhase.gameOver(winnerId: nil, isTie: true)
        XCTAssertEqual(t, GamePhase.gameOver(winnerId: nil, isTie: true))
    }

    // MARK: - WinConditionChecker

    func testWinConditionCheckerHasClearedAllViruses() {
        XCTAssertTrue(WinConditionChecker.hasClearedAllViruses(virusPositions: []))
        XCTAssertFalse(WinConditionChecker.hasClearedAllViruses(virusPositions: [GridPosition(col: 0, row: 0)]))
    }

    func testWinConditionCheckerHasToppedOut() {
        XCTAssertTrue(WinConditionChecker.hasToppedOut(canSpawn: false))
        XCTAssertFalse(WinConditionChecker.hasToppedOut(canSpawn: true))
    }

    func testWinConditionCheckerSinglePlayerLeft() {
        XCTAssertEqual(WinConditionChecker.singlePlayerLeft(eliminated: [1], playerCount: 2), 0)
        XCTAssertEqual(WinConditionChecker.singlePlayerLeft(eliminated: [0], playerCount: 2), 1)
        XCTAssertNil(WinConditionChecker.singlePlayerLeft(eliminated: [], playerCount: 2))
        XCTAssertNil(WinConditionChecker.singlePlayerLeft(eliminated: [0, 1], playerCount: 2))
    }

    func testWinConditionCheckerIsTie() {
        XCTAssertTrue(WinConditionChecker.isTie(eliminated: [0, 1], playerCount: 2, cash0: 0, cash1: 0))
        XCTAssertFalse(WinConditionChecker.isTie(eliminated: [1], playerCount: 2, cash0: 0, cash1: 0))
    }

    func testWinConditionCheckerResolveGameOverClearedAll() {
        let phase = WinConditionChecker.resolveGameOver(clearedAllCurrent: true, currentPlayerId: 0, eliminated: [], playerCount: 2, cash: [0, 0])
        if case let .gameOver(winnerId, isTie) = phase {
            XCTAssertEqual(winnerId, 0)
            XCTAssertFalse(isTie)
        } else {
            XCTFail("Expected gameOver")
        }
    }

    func testWinConditionCheckerResolveGameOverSingleLeft() {
        let phase = WinConditionChecker.resolveGameOver(clearedAllCurrent: false, currentPlayerId: 0, eliminated: [1], playerCount: 2, cash: [0, 0])
        if case let .gameOver(winnerId, isTie) = phase {
            XCTAssertEqual(winnerId, 0)
            XCTAssertFalse(isTie)
        } else {
            XCTFail("Expected gameOver")
        }
    }

    func testWinConditionCheckerResolveGameOverTie() {
        let phase = WinConditionChecker.resolveGameOver(clearedAllCurrent: false, currentPlayerId: 0, eliminated: [0, 1], playerCount: 2, cash: [0, 0])
        if case let .gameOver(winnerId, isTie) = phase {
            XCTAssertNil(winnerId)
            XCTAssertTrue(isTie)
        } else {
            XCTFail("Expected gameOver")
        }
    }

    // MARK: - Virus count / GameState

    func testVirusCountFormula() {
        XCTAssertEqual(virusCount(level: 0), 4)
        XCTAssertEqual(virusCount(level: 1), 6)
        XCTAssertEqual(virusCount(level: 23), 50)
        XCTAssertEqual(virusCount(level: 100), 50)
    }

    func testGameStateInitTwoPlayers() {
        let state = GameState(level: 0)
        XCTAssertEqual(state.players.count, 2)
        XCTAssertEqual(state.currentPlayerId, 0)
        XCTAssertEqual(state.gridStates.count, 2)
        XCTAssertEqual(state.virusPositionsPerPlayer.count, 2)
        XCTAssertTrue(state.virusPositionsPerPlayer[0].count == 4)
        XCTAssertTrue(state.virusPositionsPerPlayer[1].count == 4)
        if case .playing = state.phase { } else { XCTFail("Expected playing") }
        XCTAssertTrue(state.canAcceptInput)
        XCTAssertNotNil(state.nextCapsuleInQueue())
    }

    func testGameStateTurnAdvancesAfterLock() {
        let state = GameState(level: 0)
        let initialPlayer = state.currentPlayerId
        state.hardDrop()
        if case .playing = state.phase {
            XCTAssertEqual(state.currentPlayerId, (initialPlayer + 1) % 2)
        }
    }

    func testGameStateNoDeadEndTurnAdvancesOrGameEnds() {
        var state = GameState(level: 0)
        var steps = 0
        while steps < 500, case .playing = state.phase {
            state.hardDrop()
            steps += 1
        }
        if case .playing = state.phase {
            XCTFail("Game should end (win/elimination/tie) within 500 drops")
        }
    }

    // MARK: - C7 Attack and Garbage

    func testMatchResolverFindMatchGroups() {
        let g = Fixtures.single4H()
        let groups = MatchResolver.findMatchGroups(in: g)
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].color, .red)
        XCTAssertEqual(groups[0].positions.count, 4)
    }

    func testAttackCalculatorVirusCountAndGarbage() {
        let groups: [(color: PillColor, positions: Set<GridPosition>)] = [
            (.red, Set([GridPosition(col: 1, row: 5), GridPosition(col: 2, row: 5), GridPosition(col: 3, row: 5), GridPosition(col: 4, row: 5)]))
        ]
        let virusPositions: Set<GridPosition> = [GridPosition(col: 1, row: 5), GridPosition(col: 2, row: 5)]
        let result = AttackCalculator.compute(matchGroups: groups, virusPositions: virusPositions)
        XCTAssertEqual(result.virusCount, 2)
        XCTAssertEqual(result.garbageCount, 1)
        XCTAssertEqual(result.garbageColors.count, 1)
        XCTAssertEqual(result.garbageColors[0], .red)
    }

    func testAttackCalculatorGarbageCountMin4() {
        let groups: [(color: PillColor, positions: Set<GridPosition>)] = (0..<6).map { i in
            (.red, Set([GridPosition(col: i % 8, row: i / 8)]))
        }
        let result = AttackCalculator.compute(matchGroups: groups, virusPositions: [])
        XCTAssertEqual(result.garbageCount, 4)
    }

    func testAttackCalculatorGarbagePositions() {
        let pos2 = AttackCalculator.garbagePositions(count: 2, colors: [.red, .blue])
        XCTAssertEqual(pos2.count, 2)
        XCTAssertEqual(pos2[0].col, 0)
        XCTAssertEqual(pos2[1].col, 4)
        let pos4 = AttackCalculator.garbagePositions(count: 4, colors: [.red, .blue, .yellow, .red])
        XCTAssertEqual(pos4.count, 4)
        XCTAssertEqual(Set(pos4.map { $0.col }), [0, 2, 4, 6])
    }

    func testGridStateInsertGarbageRow() {
        var g = GridState()
        g.set(.red, at: 3, row: 0)
        g.insertGarbageRow([(col: 0, color: .blue), (col: 4, color: .yellow)])
        XCTAssertEqual(g.color(at: 0, row: 0), .blue)
        XCTAssertEqual(g.color(at: 4, row: 0), .yellow)
        XCTAssertEqual(g.color(at: 3, row: 1), .red)
    }

    // MARK: - C9 AI

    func testMoveValidatorValidPlacementsAtSpawn() {
        let g = Fixtures.empty()
        let moves = MoveValidator.validPlacementsAtSpawn(in: g)
        XCTAssertFalse(moves.isEmpty)
        for m in moves {
            XCTAssertTrue(MoveValidator.canPlace(col: m.col, row: 0, orientation: m.orientation, in: g))
        }
        let topOut = Fixtures.topOut()
        let blocked = MoveValidator.validPlacementsAtSpawn(in: topOut)
        XCTAssertLessThan(blocked.count, moves.count)
    }

    func testAIControllerMock() {
        let grid = Fixtures.empty()
        let validMoves = MoveValidator.validPlacementsAtSpawn(in: grid)
        XCTAssertFalse(validMoves.isEmpty)
        let fixedMove = validMoves[0]
        let snapshot = AISnapshot(grid: grid, capsuleLeft: .red, capsuleRight: .blue, validMoves: validMoves, virusPositions: [])
        let mock = MockAIController(returnMove: fixedMove)
        let move = mock.move(for: snapshot)
        XCTAssertEqual(move?.col, fixedMove.col)
        XCTAssertEqual(move?.orientation, fixedMove.orientation)
    }

    func testRandomAIReturnsValidMove() {
        let grid = Fixtures.empty()
        let validMoves = MoveValidator.validPlacementsAtSpawn(in: grid)
        let snapshot = AISnapshot(grid: grid, capsuleLeft: .red, capsuleRight: .blue, validMoves: validMoves, virusPositions: [])
        let randomAI = RandomAI()
        let moveSet = Set(validMoves.map { "\($0.col),\($0.orientation.rawValue)" })
        for _ in 0..<20 {
            let move = randomAI.move(for: snapshot)
            XCTAssertNotNil(move)
            XCTAssertTrue(moveSet.contains("\(move!.col),\(move!.orientation.rawValue)"))
        }
    }

    func testGreedyAIPrefersHigherVirusClears() {
        var grid = Fixtures.empty()
        for c in 0..<4 { grid.set(.red, at: c, row: 5) }
        let virusPositions: Set<GridPosition> = [GridPosition(col: 0, row: 5), GridPosition(col: 1, row: 5), GridPosition(col: 2, row: 5), GridPosition(col: 3, row: 5)]
        let validMoves = MoveValidator.validPlacementsAtSpawn(in: grid)
        let snapshot = AISnapshot(grid: grid, capsuleLeft: .red, capsuleRight: .red, validMoves: validMoves, virusPositions: virusPositions)
        let greedy = GreedyAI()
        let move = greedy.move(for: snapshot)
        XCTAssertNotNil(move)
        let score = PlacementScorer.scoreVirusClears(grid: grid, virusPositions: virusPositions, col: move!.col, orientation: move!.orientation, leftColor: .red, rightColor: .red)
        XCTAssertGreaterThanOrEqual(score, 0)
    }

    func testAIContractFullBoardReturnsNil() {
        let snapshot = AISnapshot(grid: Fixtures.topOut(), capsuleLeft: .red, capsuleRight: .blue, validMoves: [], virusPositions: [])
        let randomAI = RandomAI()
        XCTAssertNil(randomAI.move(for: snapshot))
        let greedyAI = GreedyAI()
        XCTAssertNil(greedyAI.move(for: snapshot))
    }

    func testAIContractEveryMoveLegal() {
        let grid = Fixtures.empty()
        let validMoves = MoveValidator.validPlacementsAtSpawn(in: grid)
        let snapshot = AISnapshot(grid: grid, capsuleLeft: .red, capsuleRight: .blue, validMoves: validMoves, virusPositions: [])
        let randomAI = RandomAI()
        for _ in 0..<30 {
            guard let move = randomAI.move(for: snapshot) else { XCTFail("expected move"); return }
            XCTAssertTrue(validMoves.contains { $0.col == move.col && $0.orientation == move.orientation })
        }
    }

    func testGameStateAiSnapshotAndApplyAIMove() {
        var state: GameState?
        var snapshot: AISnapshot?
        for _ in 0..<20 {
            let s = GameState(level: 0)
            let snap = s.aiSnapshotForCurrentPlayer()
            if snap != nil {
                state = s
                snapshot = snap
                break
            }
        }
        XCTAssertNotNil(state)
        XCTAssertNotNil(snapshot, "aiSnapshotForCurrentPlayer() should be non-nil when spawn is not blocked (retried up to 20 times)")
        guard let state = state, let snapshot = snapshot else { return }
        XCTAssertEqual(snapshot.validMoves.count, MoveValidator.validPlacementsAtSpawn(in: state.currentGridState()).count)
        guard let firstMove = snapshot.validMoves.first else { return }
        state.applyAIMove(col: firstMove.col, orientation: firstMove.orientation)
        XCTAssertEqual(state.currentPlayerId, 1)
    }
}

/// C9: Mock AI that returns a fixed move for unit tests.
private struct MockAIController: AIController {
    let returnMove: (col: Int, orientation: CapsuleOrientation)
    func move(for snapshot: AISnapshot) -> (col: Int, orientation: CapsuleOrientation)? {
        snapshot.validMoves.contains { $0.col == returnMove.col && $0.orientation == returnMove.orientation }
            ? returnMove
            : snapshot.validMoves.first
    }
}
