---
name: P005 M5 Ads After Win
overview: Integrate ad SDK; show ads only after a win, only for free users (!hasPremium).
---

**Next hand off (cut & paste)**: **P005 M5 — Ads after win.** [M5-ads-after-win.plan.md](.cursor/Plans/P005/M5-ads-after-win.plan.md). Investigator: validate M5 for 90%+ confidence. Builder: Integrate AdMob or Unity Ads; show interstitial or rewarded ad in GameOverOverlay / post-win flow when !IAPManager.shared.hasPremium.

---

## Outcome

Free users see an ad **only after winning** a game (at game over). Paid users (hasPremium) never see ads. Ad placement: interstitial or rewarded video in the game-over flow.

---

## Strategy (from main plan)

| Tier | Ads |
|------|-----|
| Free | Ads after win only |
| Paid | No ads |

---

## Steps

1. **Choose ad SDK**  
   - AdMob (Google) or Unity Ads. AdMob common for iOS; Unity lighter for games.  
   - Add SDK via SPM or CocoaPods

2. **Create AdManager**  
   - Path: `TableTopGame/Monetization/AdManager.swift`  
   - `func shouldShowAd() -> Bool` — returns `!IAPManager.shared.hasPremium`  
   - `func showInterstitialAfterWin(onDismiss: (() -> Void)?)` — loads and presents interstitial; calls onDismiss when closed  
   - Initialize ad SDK at app launch (in TableTopGameApp or similar)

3. **Integrate into game-over flow**  
   - Path: [GameView.swift](TableTopGame/GameView.swift) — GameOverOverlay or equivalent  
   - When game over (win only — not tie/lose unless product prefers): if `AdManager.shouldShowAd()`, call `AdManager.showInterstitialAfterWin { /* continue to overlay */ }` before or as overlay appears  
   - **Win-only**: Show ad only when game ends with a winner (not tie, not loss). For 1P vs AI: show only when human won (`winnerId == 0`). For 2P local: either player won = show ad (both shared the session).  
   - Ensure ad does not block Restart/Return to Menu; show ad first, then overlay, or show overlay with brief delay then ad

4. **Privacy and App Store**  
   - Update App Privacy: declare identifiers, usage data per ad SDK requirements  
   - AdMob/Unity require IDFA declaration if using; consider ATT prompt timing

5. **Unit/test**  
   - When hasPremium true: no ad shown  
   - When hasPremium false: ad shown (or placeholder) after win

---

## Dependencies

- M1 complete (IAPManager.hasPremium exists)

---

## Technical Detail

- **Ad placement**: Interstitial after win. Alternative: rewarded (watch for reward) — same gate.  
- **Win detection**: GamePhase.gameOver(winnerId, isTie) — show ad only when !isTie (has a winner).  
- **2P local**: Both players "saw" the game; ad shows once at game over. No need to distinguish which player won for ad purpose.

---

## Validation

- Manual: Free user wins → ad appears; paid user wins → no ad  
- Manual: Free user loses or ties → no ad (win only)  
- XCUITest: Mock hasPremium; verify ad view presented or not

---

## Rollback

Remove AdManager; remove ad SDK; remove ad call from game-over flow. Revert Privacy label if changed.

---

## Confidence

| | % |
|---|---|
| Confidence (root cause) | 88% |
| Confidence (solution path) | 88% |

**Note**: Ad SDK choice (AdMob vs Unity) and exact placement (before overlay vs embedded) need product decision. Investigator to tighten.
