import Foundation

/// Virus count per level. SPEC: min(4 + level × 2, 50).
func virusCount(level: Int) -> Int {
    min(4 + level * 2, 50)
}

/// Generates virus positions for one player at the given level. Balanced colors, random valid positions.
func makeInitialViruses(level: Int) -> [Virus] {
    let count = virusCount(level: level)
    let colors = PillColor.allCases
    var viruses: [Virus] = []
    var used: Set<GridPosition> = []
    for i in 0..<count {
        let color = colors[i % colors.count]
        var col: Int, row: Int
        repeat {
            col = Int.random(in: 0..<Grid.columns)
            row = Int.random(in: 0..<Grid.rows)
        } while used.contains(GridPosition(col: col, row: row))
        used.insert(GridPosition(col: col, row: row))
        viruses.append(Virus(col: col, row: row, color: color))
    }
    return viruses
}

/// Two-player game state: turn order, two grids, virus positions, win/elimination, capsule queue.
final class GameState {

    static let numberOfPlayers = 2
    static let spawnCol = 3
    static let spawnRow = 0
    static let initialOrientation: CapsuleOrientation = .right

    private(set) var players: [Player]
    private(set) var gridStates: [GridState]
    /// Virus positions per player (indices into grid). Emptied as viruses are cleared.
    private(set) var virusPositionsPerPlayer: [Set<GridPosition>]
    private(set) var eliminated: Set<Int>
    /// Cash per player (1 per virus cleared). Used for tiebreaker.
    private(set) var cash: [Int]
    private(set) var currentPlayerIndex: Int
    private(set) var phase: GamePhase

    /// Current capsule in play (only valid when phase == .playing and not eliminated).
    private(set) var capsuleCol: Int
    private(set) var capsuleRow: Int
    private(set) var capsuleOrientation: CapsuleOrientation
    private(set) var capsuleLeftColor: PillColor
    private(set) var capsuleRightColor: PillColor
    private(set) var isCapsuleLocked: Bool

    /// Queue of (left, right) colors for next capsules. Refilled on spawn.
    private var capsuleQueue: [(PillColor, PillColor)]

    /// C7: Pending garbage rows to insert (per player). Garbage targets opponent; never to eliminated.
    private var pendingGarbage: [[[(col: Int, color: PillColor)]]]

    /// Current player's grid (read-only for display/validation).
    func currentGridState() -> GridState {
        gridStates[currentPlayerIndex]
    }

    /// C8: Grid for a given player (read-only for head-to-head layout).
    func gridState(forPlayer playerIndex: Int) -> GridState {
        gridStates[playerIndex]
    }

    /// C9: Virus positions for a player (for AI snapshot / Greedy scoring).
    func virusPositions(forPlayer playerIndex: Int) -> Set<GridPosition> {
        guard playerIndex >= 0, playerIndex < virusPositionsPerPlayer.count else { return [] }
        return virusPositionsPerPlayer[playerIndex]
    }

    /// Current player id.
    var currentPlayerId: Int { currentPlayerIndex }

    /// True if the current player can receive input (playing, not locked, not eliminated).
    var canAcceptInput: Bool {
        if case .gameOver = phase { return false }
        if eliminated.contains(currentPlayerIndex) { return false }
        if isCapsuleLocked { return false }
        return true
    }

    /// True when spawn is blocked for current player (top-out).
    func isSpawnBlocked(forPlayerIndex playerIndex: Int) -> Bool {
        let grid = gridStates[playerIndex]
        return !MoveValidator.canPlace(col: Self.spawnCol, row: Self.spawnRow, orientation: Self.initialOrientation, in: grid)
    }

    init(level: Int = 0) {
        self.players = (0..<Self.numberOfPlayers).map { Player(id: $0) }
        self.gridStates = []
        self.virusPositionsPerPlayer = []
        self.eliminated = []
        self.cash = [0, 0]
        self.currentPlayerIndex = 0
        self.phase = .playing
        self.capsuleCol = Self.spawnCol
        self.capsuleRow = Self.spawnRow
        self.capsuleOrientation = Self.initialOrientation
        self.capsuleLeftColor = .red
        self.capsuleRightColor = .blue
        self.isCapsuleLocked = false
        self.capsuleQueue = []
        self.pendingGarbage = Array(repeating: [], count: Self.numberOfPlayers)

        for _ in 0..<Self.numberOfPlayers {
            let viruses = makeInitialViruses(level: level)
            var grid = GridState()
            var positions = Set<GridPosition>()
            for v in viruses {
                grid.addViruses([v])
                positions.insert(GridPosition(col: v.col, row: v.row))
            }
            gridStates.append(grid)
            virusPositionsPerPlayer.append(positions)
        }

        refillCapsuleQueue()
        spawnCurrentPlayer()
    }

    /// Test-only init with fixture grid states. Used for deterministic top-out and lose-scenario tests.
    /// - Parameters:
    ///   - gridStatesForTest: [P0 grid, P1 grid]. P0 goes first.
    ///   - capsuleQueueForTest: Initial capsule queue. Must have at least one element. Default: [(.red, .blue)].
    init(gridStatesForTest gridStates: [GridState], capsuleQueueForTest: [(PillColor, PillColor)] = [(.red, .blue)]) {
        precondition(gridStates.count == Self.numberOfPlayers)
        precondition(!capsuleQueueForTest.isEmpty)
        self.players = (0..<Self.numberOfPlayers).map { Player(id: $0) }
        self.gridStates = gridStates
        self.virusPositionsPerPlayer = Array(repeating: [], count: Self.numberOfPlayers)
        self.eliminated = []
        self.cash = [0, 0]
        self.currentPlayerIndex = 0
        self.phase = .playing
        self.capsuleCol = Self.spawnCol
        self.capsuleRow = Self.spawnRow
        self.capsuleOrientation = Self.initialOrientation
        self.capsuleLeftColor = .red
        self.capsuleRightColor = .blue
        self.isCapsuleLocked = false
        self.capsuleQueue = capsuleQueueForTest
        self.pendingGarbage = Array(repeating: [], count: Self.numberOfPlayers)
        refillCapsuleQueue()
        spawnCurrentPlayer()
    }

    private func refillCapsuleQueue() {
        while capsuleQueue.count < 2 {
            let left = PillColor.allCases.randomElement() ?? .red
            let right = PillColor.allCases.randomElement() ?? .blue
            capsuleQueue.append((left, right))
        }
    }

    /// Spawn capsule for current player. If blocked, mark eliminated and advance until someone can spawn or game over.
    private func spawnCurrentPlayer() {
        if case .gameOver = phase { return }
        if eliminated.contains(currentPlayerIndex) {
            advanceTurn()
            return
        }
        let (left, right) = capsuleQueue.removeFirst()
        refillCapsuleQueue()
        capsuleCol = Self.spawnCol
        capsuleRow = Self.spawnRow
        capsuleOrientation = Self.initialOrientation
        capsuleLeftColor = left
        capsuleRightColor = right
        isCapsuleLocked = false

        let grid = gridStates[currentPlayerIndex]
        if !MoveValidator.canPlace(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: grid) {
            eliminated.insert(currentPlayerIndex)
            if let winner = WinConditionChecker.singlePlayerLeft(eliminated: eliminated, playerCount: Self.numberOfPlayers) {
                phase = .gameOver(winnerId: winner, isTie: false)
                return
            }
            if WinConditionChecker.isTie(eliminated: eliminated, playerCount: Self.numberOfPlayers, cash0: cash[0], cash1: cash[1]) {
                phase = .gameOver(winnerId: nil, isTie: true)
                return
            }
            advanceTurn()
            return
        }
    }

    /// Advance to next non-eliminated player and spawn. If none or one left, set game over.
    private func advanceTurn() {
        if case .gameOver = phase { return }
        var next = (currentPlayerIndex + 1) % Self.numberOfPlayers
        var attempts = 0
        while eliminated.contains(next), attempts < Self.numberOfPlayers {
            next = (next + 1) % Self.numberOfPlayers
            attempts += 1
        }
        if eliminated.contains(next) {
            phase = .gameOver(winnerId: nil, isTie: true)
            return
        }
        currentPlayerIndex = next
        if let sole = WinConditionChecker.singlePlayerLeft(eliminated: eliminated, playerCount: Self.numberOfPlayers) {
            phase = .gameOver(winnerId: sole, isTie: false)
            return
        }
        spawnCurrentPlayer()
    }

    // MARK: - Input (move/rotate/drop)

    func tryMoveLeft() {
        guard canAcceptInput else { return }
        guard MoveValidator.canMoveLeft(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: gridStates[currentPlayerIndex]) else { return }
        capsuleCol -= 1
    }

    func tryMoveRight() {
        guard canAcceptInput else { return }
        guard MoveValidator.canMoveRight(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: gridStates[currentPlayerIndex]) else { return }
        capsuleCol += 1
    }

    func tryMoveDown() {
        guard canAcceptInput else { return }
        let grid = gridStates[currentPlayerIndex]
        if !MoveValidator.canMoveDown(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: grid) {
            lockCapsule()
            return
        }
        capsuleRow += 1
    }

    func tryRotate() {
        guard canAcceptInput else { return }
        let grid = gridStates[currentPlayerIndex]
        guard let result = MoveValidator.rotateWithWallKick(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, clockwise: true, in: grid) else { return }
        capsuleCol = result.col
        capsuleOrientation = result.orientation
    }

    func hardDrop() {
        guard canAcceptInput else { return }
        let grid = gridStates[currentPlayerIndex]
        while MoveValidator.canMoveDown(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: grid) {
            capsuleRow += 1
        }
        lockCapsule()
    }

    /// Lock capsule, resolve match+gravity, apply pending garbage, compute attack, advance turn.
    func lockCapsule() {
        guard canAcceptInput else { return }
        isCapsuleLocked = true
        let pid = currentPlayerIndex
        var grid = gridStates[pid]
        var virusPositions = virusPositionsPerPlayer[pid]

        // C7: Apply pending garbage (Trash phase). Insert one row at a time, resolve after each.
        while !pendingGarbage[pid].isEmpty {
            let row = pendingGarbage[pid].removeFirst()
            grid.insertGarbageRow(row)
            resolveLoop(grid: &grid, virusPositions: &virusPositions, pid: pid)
        }
        let virusPositionsBeforeCapsule = virusPositions

        let segs = MoveValidator.segments(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation)
        grid.set(capsuleLeftColor, at: segs[0].col, row: segs[0].row)
        grid.set(capsuleRightColor, at: segs[1].col, row: segs[1].row)

        var allMatchGroups: [(color: PillColor, positions: Set<GridPosition>)] = []
        while true {
            let groups = MatchResolver.findMatchGroups(in: grid)
            if groups.isEmpty { break }
            allMatchGroups.append(contentsOf: groups)
            for (_, positions) in groups {
                for pos in positions {
                    if virusPositions.contains(pos) {
                        cash[pid] += 1
                        virusPositions.remove(pos)
                    }
                    grid.remove(at: pos.col, row: pos.row)
                }
            }
            while GravityEngine.apply(to: &grid) { }
        }

        gridStates[pid] = grid
        virusPositionsPerPlayer[pid] = virusPositions

        // C7: Compute attack, enqueue garbage for opponent (never to eliminated).
        let opponent = (pid + 1) % Self.numberOfPlayers
        if !eliminated.contains(opponent) {
            let result = AttackCalculator.compute(matchGroups: allMatchGroups, virusPositions: virusPositionsBeforeCapsule)
            if result.garbageCount > 0 {
                let row = AttackCalculator.garbagePositions(count: result.garbageCount, colors: result.garbageColors)
                    .map { (col: $0.col, color: $0.color) }
                pendingGarbage[opponent].append(row)
            }
        }

        let clearedAll = WinConditionChecker.hasClearedAllViruses(virusPositions: virusPositions)
        phase = WinConditionChecker.resolveGameOver(
            clearedAllCurrent: clearedAll,
            currentPlayerId: pid,
            eliminated: eliminated,
            playerCount: Self.numberOfPlayers,
            cash: cash
        )
        if case .gameOver = phase { return }
        advanceTurn()
    }

    /// Resolution loop: clear matches, gravity, repeat until stable.
    private func resolveLoop(grid: inout GridState, virusPositions: inout Set<GridPosition>, pid: Int) {
        while true {
            let groups = MatchResolver.findMatchGroups(in: grid)
            if groups.isEmpty { break }
            for (_, positions) in groups {
                for pos in positions {
                    if virusPositions.contains(pos) {
                        cash[pid] += 1
                        virusPositions.remove(pos)
                    }
                    grid.remove(at: pos.col, row: pos.row)
                }
            }
            while GravityEngine.apply(to: &grid) { }
        }
    }

    /// Next capsule in queue (for preview). Returns (left, right) or nil.
    func nextCapsuleInQueue() -> (PillColor, PillColor)? {
        capsuleQueue.first
    }

    // MARK: - C9 AI

    /// Read-only snapshot for AI: grid, capsule colors, valid moves at spawn, virus positions. Returns nil when current player cannot accept input.
    func aiSnapshotForCurrentPlayer() -> AISnapshot? {
        guard canAcceptInput else { return nil }
        let grid = gridStates[currentPlayerIndex]
        let validMoves = MoveValidator.validPlacementsAtSpawn(in: grid)
        let virusPositions = virusPositionsPerPlayer[currentPlayerIndex]
        return AISnapshot(
            grid: grid,
            capsuleLeft: capsuleLeftColor,
            capsuleRight: capsuleRightColor,
            validMoves: validMoves,
            virusPositions: virusPositions
        )
    }

    /// Apply AI-chosen move: set capsule at spawn to (col, orientation) and hard-drop. No-op if invalid or not accepting input.
    func applyAIMove(col: Int, orientation: CapsuleOrientation) {
        guard canAcceptInput else { return }
        let grid = gridStates[currentPlayerIndex]
        guard MoveValidator.canPlace(col: col, row: Self.spawnRow, orientation: orientation, in: grid) else { return }
        capsuleCol = col
        capsuleRow = Self.spawnRow
        capsuleOrientation = orientation
        hardDrop()
    }
}
