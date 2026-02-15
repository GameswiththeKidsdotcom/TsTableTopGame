---
name: P005 M2 Paywall UI
overview: Add purchase and restore buttons to Settings or Menu; wire to IAPManager.
---

**Next hand off (cut & paste)**: **P005 M2 — Paywall UI.** [M2-paywall-ui.plan.md](.cursor/Plans/subplans/P005/M2-paywall-ui.plan.md). Investigator: validate M2 for 90%+ confidence. Builder: add purchase and restore buttons in SettingsView; wire to IAPManager.shared; show/hide based on hasPremium.

---

## Outcome

User can tap "Remove Ads & Unlock Power-ups" (or equivalent) to purchase, and "Restore Purchases" to sync. If already purchased, show "Unlocked" or hide section. Copy communicates: eliminates ads, unlocks power-ups anytime.

---

## Steps

1. **Inject IAPManager into SettingsView**  
   - Use `@StateObject private var iapManager = IAPManager.shared` (or inject via environment)  
   - Ensure IAPManager is initialized at app launch (e.g. in TableTopGameApp or RootView)

2. **Add "Unlock" section to SettingsView**  
   - Path: [SettingsView.swift](TableTopGame/SettingsView.swift)  
   - Section "Premium" (or "Unlock")  
   - Copy: "Remove Ads & Unlock Power-ups" — explains paid benefits (no ads after win; power-ups anytime)  
   - If `!iapManager.hasPremium`: show purchase button (calls `Task { await iapManager.purchase(product) }`)  
   - Show "Restore Purchases" button  
   - If `iapManager.hasPremium`: show "Unlocked" or checkmark; hide purchase button  
   - Show loading state when `iapManager.purchaseInProgress`

3. **Alternative: Menu paywall**  
   - If preferred, add "Upgrade" or "Remove Ads & Unlock Power-ups" to [MenuView](RootView.swift) instead of Settings  
   - Same wiring pattern

4. **Error handling**  
   - On `purchase()` failure: show alert (user cancelled vs error)  
   - On restore: silently update; show brief "Restored" toast if successful

5. **Accessibility**  
   - Add `accessibilityIdentifier` for "unlockButton", "restoreButton" for UI tests

---

## Dependencies

- M1 complete (IAPManager exists and loads product)

---

## Technical Detail

- **SwiftUI**: `Button` with `Task { }` for async purchase  
- **Product**: Use first product from `iapManager.products` (or explicit unlock product)  
- **Placement**: Settings is less intrusive; Menu offers higher visibility

---

## Validation

- Manual: Open Settings; tap Unlock; complete or cancel purchase flow  
- Manual: Tap Restore; confirm hasPremium updates if previously purchased  
- XCUITest (optional): Tap unlock button; dismiss system sheet (cancel) — no crash

---

## Rollback

Remove Unlock section from SettingsView; revert to previous SettingsView. IAPManager remains but unused.

---

## Confidence

| | % |
|---|---|
| Confidence (root cause) | 90% |
| Confidence (solution path) | 90% |

**Note**: Straightforward UI wiring. Investigator to validate placement (Settings vs Menu) if product preference unclear.
