---
name: P005 Monetization
overview: Add StoreKit 2 IAP to TableTopGame. Paid unlock removes ads and grants power-ups anytime; free users see ads after win only. Sub-plans under .cursor/Plans/subplans/P005/. Delegate Investigator before M1; UI-Test and Logic-Test at M4.
---

# P005 – Monetization

**Next hand off (cut & paste)**: **P005 M1 — IAPManager.** [M1-iap-manager.plan.md](M1-iap-manager.plan.md). Investigator: validate M1 for 90%+ confidence. Builder: create `IAPManager` wrapping StoreKit 2; `IAPProductIDs`; entitlement check via `Transaction.currentEntitlements`. Unit test with StoreKit Configuration (M4 provides config file).

---

## Monetization Strategy

| Tier | Ads | Power-ups |
|------|-----|-----------|
| **Free** | Ads **only after a win** (interstitial or rewarded at game over) | Only during turn with in-game cash (P004 standard flow) |
| **Paid** (IAP unlock) | No ads | Can buy power-ups **any time** (no turn restriction; in-game cash) |

**Paid unlock** = non-consumable IAP `com.tabletopgame.app.unlock`. Entitlement gates: (1) ad display, (2) power-up purchase availability (when P004 exists).

---

## Scope

- **Approach**: Quick MVP — free app with one non-consumable IAP.
- **Features**: IAP flow; ads after win (free only); power-up gating (paid = anytime; free = turn-only when P004 built).
- **Objects**: IAPManager, IAPProductIDs, AdManager, PaywallView (or purchase button in Settings), StoreKit Configuration.

**Reference**: Full approach comparison in ideation plan (Quick MVP, Scalable, Innovative).

---

## Feature → Object Map

| Feature | Objects | Dependencies |
|---------|---------|--------------|
| Load/purchase/restore | IAPManager, IAPProductIDs | StoreKit 2 |
| Entitlement check | IAPManager.hasPremium | M1 |
| Purchase UI | PaywallView or Settings purchase button | M1 |
| Ads after win (free only) | AdManager, ad SDK (AdMob/Unity); GameOverOverlay or RootView | M1 |
| Power-up anytime (paid only) | GameState / HUDOverlay gating; P004 power-up flow | P004, M1 |
| ASC products | App Store Connect product; age rating runbook update | Human in ASC |
| Local testing | StoreKit Configuration file | Xcode project |

**Dependency order**: M1 → M2, M5 (ads) | M3 (ASC parallel); M4 enables M1 tests. Power-up gating (M5b or P004 integration) requires P004.

---

## Chunks

| Chunk | Outcome | Sub-plan |
|-------|---------|----------|
| **M1** | IAPManager + StoreKit 2 wiring; entitlement check | [M1-iap-manager.plan.md](M1-iap-manager.plan.md) |
| **M2** | Paywall UI (purchase/restore; "Remove Ads & Unlock Power-ups") | [M2-paywall-ui.plan.md](M2-paywall-ui.plan.md) |
| **M3** | ASC product created; age rating runbook updated | [M3-asc-products.plan.md](M3-asc-products.plan.md) |
| **M4** | StoreKit Configuration file; entitlement unit tests | [M4-storekit-testing.plan.md](M4-storekit-testing.plan.md) |
| **M5** | Ad integration — ads after win only, gated by !hasPremium | [M5-ads-after-win.plan.md](M5-ads-after-win.plan.md) |
| **M6** | Power-up anytime gating (paid); integrate with P004 when built | [M6-powerup-gating.plan.md](M6-powerup-gating.plan.md) |

**Note**: M4 can be done before or with M1. M5 (ads) requires Ad SDK; M6 requires P004 power-up system.

---

## App Store Impact

- Age rating: In-App Purchases → Yes (update [asc-setup-runbook.md](../P001-C11/asc-setup-runbook.md))
- Privacy: IAP only — no new data. **Ads** — declare identifiers/usage per SDK (AdMob/Unity); update App Privacy if ads added.
- P001-C11: Monetization can land before or after first submission

---

## Risks & Rollback

| Risk | Mitigation |
|------|-------------|
| ASC/StoreKit setup blocks submission | Use StoreKit Configuration for local tests; validate in Sandbox |
| Regression | Feature-flag `hasPremium` default true to effectively make free |

**Rollback**: Remove purchase UI; keep `hasPremium` default true. Products can stay inactive in ASC.
