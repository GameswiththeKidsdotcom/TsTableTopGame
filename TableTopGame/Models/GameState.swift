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

    /// Current player's grid (read-only for display/validation).
    func currentGridState() -> GridState {
        gridStates[currentPlayerIndex]
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
        var grid = gridStates[currentPlayerIndex]
        while MoveValidator.canMoveDown(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation, in: grid) {
            capsuleRow += 1
        }
        lockCapsule()
    }

    /// Lock capsule, resolve match+gravity, update virus/cash, check win/elimination, advance turn.
    func lockCapsule() {
        guard canAcceptInput else { return }
        isCapsuleLocked = true
        let pid = currentPlayerIndex
        var grid = gridStates[pid]
        var virusPositions = virusPositionsPerPlayer[pid]

        let segs = MoveValidator.segments(col: capsuleCol, row: capsuleRow, orientation: capsuleOrientation)
        grid.set(capsuleLeftColor, at: segs[0].col, row: segs[0].row)
        grid.set(capsuleRightColor, at: segs[1].col, row: segs[1].row)

        while true {
            let matches = MatchResolver.findMatches(in: grid)
            if matches.isEmpty { break }
            for pos in matches {
                if virusPositions.contains(pos) {
                    cash[pid] += 1
                    virusPositions.remove(pos)
                }
                grid.remove(at: pos.col, row: pos.row)
            }
            while GravityEngine.apply(to: &grid) { }
        }

        gridStates[pid] = grid
        virusPositionsPerPlayer[pid] = virusPositions

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

    /// Next capsule in queue (for preview). Returns (left, right) or nil.
    func nextCapsuleInQueue() -> (PillColor, PillColor)? {
        capsuleQueue.first
    }
}
