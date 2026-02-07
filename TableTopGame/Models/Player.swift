import Foundation

/// A player in the head-to-head (2-player) game. Used for board ownership and avatars.
struct Player {
    let id: Int
    var name: String

    init(id: Int, name: String? = nil) {
        self.id = id
        self.name = name ?? "Player \(id)"
    }
}
