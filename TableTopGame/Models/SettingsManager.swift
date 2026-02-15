import Foundation
import Combine

/// C10: UserDefaults-backed settings (sound, AI delay). Persists across sessions.
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard
    private static let soundEnabledKey = "soundEnabled"
    private static let aiDelaySecondsKey = "aiDelaySeconds"
    private static let gameLevelKey = "gameLevel"
    private static let defaultSoundEnabled = true
    private static let defaultAiDelaySeconds = 1.5
    private static let defaultGameLevel = 0

    @Published var soundEnabled: Bool {
        didSet {
            defaults.set(soundEnabled, forKey: Self.soundEnabledKey)
        }
    }

    @Published var aiDelaySeconds: Double {
        didSet {
            defaults.set(aiDelaySeconds, forKey: Self.aiDelaySecondsKey)
        }
    }

    @Published var gameLevel: Int {
        didSet {
            defaults.set(gameLevel, forKey: Self.gameLevelKey)
        }
    }

    private init() {
        self.soundEnabled = defaults.object(forKey: Self.soundEnabledKey) as? Bool ?? Self.defaultSoundEnabled
        self.aiDelaySeconds = defaults.object(forKey: Self.aiDelaySecondsKey) as? Double ?? Self.defaultAiDelaySeconds
        self.gameLevel = defaults.object(forKey: Self.gameLevelKey) as? Int ?? Self.defaultGameLevel
    }
}
