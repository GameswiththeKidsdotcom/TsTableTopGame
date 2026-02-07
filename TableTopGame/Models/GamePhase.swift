import Foundation

/// Game outcome phase. Playing = turn in progress; gameOver = winner or tie.
enum GamePhase: Equatable {
    case playing
    case gameOver(winnerId: Int?, isTie: Bool)
}
