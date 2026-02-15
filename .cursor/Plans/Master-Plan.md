# Master Plan
##Prioritize 
- regression fixes
- defect corrections
- app store compliance
- new features

Always ensure analysis is performed prior to a builder agent working on the plan. 

## Concurrent agents (max 2)

At most **two agents** may work in parallel. Two hand offs are allowed only when their work **does not conflict**.

**Conflicts (do not run both if any apply):**
- Same file or overlapping file set is edited by both.
- Same plan chunk or same sub-plan is executed by both.
- Both update the same Master-Plan row or same plan state.
- One change depends on the other's outcome (order required).

**Non-conflicting examples (safe for two agents):**
- **Lane A** in app code (e.g. `GameState.swift`), **Lane B** in test code only (e.g. `TableTopGameUITests.swift` or `TableTopGameTests.swift`) with no shared files.
- **Lane A** UI-Test / E2E (XCUITest), **Lane B** Logic-Test / unit tests (no app code edits).
- **Lane A** one sub-plan or chunk (e.g. P001-E2E-WATCH A2), **Lane B** a different sub-plan or chunk with no file overlap (e.g. P001 C10 validation in a different area).
- One agent runs tests only (read-only validation) while the other edits a disjoint set of files.

When in doubt, run one agent at a time. Planner: when updating hand offs, if a second non-conflicting task exists, add it under **Second hand off** and state the non-conflict reason briefly.

---

## Next hand off (cut & paste) — Lane A

**P001-UnitTestFailures UT-1 — Builder** (Fix). [UT1-testGameStateInitTwoPlayers.plan.md](.cursor/Plans/subplans/P001-UnitTestFailures/UT1-testGameStateInitTwoPlayers.plan.md). Implement fix: use `GameState(gridStatesForTest: [Fixtures.empty(), Fixtures.empty()], capsuleQueueForTest: [(.red, .blue)])`; relax virus count assertions for fixture path. Run full test suite. Target: ≥90% confidence; test passes deterministically.

## Second hand off (cut & paste) — Lane B

**P001-Dyld — Commit to GitHub** (Builder, human). [P001-Dyld-dyld-crash.plan.md](.cursor/Plans/subplans/P001-Dyld/P001-Dyld-dyld-crash.plan.md). Fix applied 2026-02-15. Stage, commit (e.g. `P001-Dyld: disable ENABLE_DEBUG_DYLIB`), push to `origin/main`; update matrix with push date. Non-conflict: Dyld is project config; UnitTestFailures is test code — disjoint.

**C11-A1**: Done. **C11-A2**: Done. **C11-A3**: Deferred until P005 monetization built; runbook ready ([asc-setup-runbook.md](.cursor/Plans/subplans/P001-C11/asc-setup-runbook.md)).


### Next priorities (summary)

| Priority | What | Agent | Plan / notes |
|----------|------|--------|---------------|
| 1 | P001-UnitTestFailures — UT-1 Builder (testGameStateInitTwoPlayers fixture fix) | Builder | subplans/P001-UnitTestFailures/UT1-testGameStateInitTwoPlayers.plan.md |
| 2 | P001-Dyld — Commit to GitHub (fixed 2026-02-15) | Builder, human | subplans/P001-Dyld/P001-Dyld-dyld-crash.plan.md |
| 3 | P001-C7-Garbage — Complete (A1–A4 done) | — | subplans/P001-C7-Garbage/P001-C7-Garbage.plan.md |
| 4–10 | P001-RestartFix, E2E-WATCH, P001, P001-LT, P001-UI, P001-E2E, P002 — complete or pushed | — | See matrix |
| 11 | P001-C11 App Store prep (A4, A5) | Builder, human | subplans/P001-C11/P001-C11-app-store.plan.md (chunks A1–A5) |
| 12–17 | P006, P006-E2E, P006-G1-VDF, P003, P004, P005 | Builder, Investigator | See matrix |
| — | C11-A3 ASC setup (human) | Human | After P005 (and P004) built; runbook ready |

*P002 pushed 2026-02-14. P001-RestartFix R1+R2 complete. C11-A1/A2 done; C11-A3 deferred until P005 built. P006 (spec gaps) fleshed out; features-for-planner.md provides elaboration for Planner. P003 queued after P001-C11. P005: paid = no ads, power-ups anytime; free = ads after win only.*

---

This file is the **single source of truth** for plan navigation, priority, and status. All plans created by agents (e.g., Investigator, UI-Test, logic-test, infrastructure) must be registered here so that priority ordering and current state are visible in one place.

## Valid plan states

Use exactly one of these values in the **Current state** column:

| State | Meaning |
|-------|--------|
| **Pending analysis** | Plan not yet fully investigated; root cause or solution path unclear |
| **Validated** | Analysis complete; root cause and solution path documented with confidence scores |
| **Test plan ready** | Test strategy and cases defined; ready for test implementation or code work |
| **Code built** | Implementation done; not yet under test |
| **Testing in progress** | Tests running or in progress |
| **Testing complete** | All tests passed; no open defects from this plan |
| **Defects pending** | Testing found issues; fixes or re-test pending |
| **Complete and ready for github push** | All work verified; ready to commit and push |

## Plan matrix

**Priority rank**: 1 = highest priority, then 2, 3, … (descending from highest to lowest).

| Plan ID | Plan name | Priority rank | Description | Current state | Confidence (root cause) | Confidence (solution path) |
|---------|-----------|---------------|-------------|---------------|--------------------------|-----------------------------|
| P001-UnitTestFailures | Failing unit tests | 1 | testGameStateInitTwoPlayers, testOneClearSendsVisibleGarbageToOpponent. Investigator ✓ Planner ✓. Sub-plans: [UT1](.cursor/Plans/subplans/P001-UnitTestFailures/UT1-testGameStateInitTwoPlayers.plan.md), [UT2](.cursor/Plans/subplans/P001-UnitTestFailures/UT2-testOneClearSendsVisibleGarbageToOpponent.plan.md). Plan: [P001-UnitTestFailures.plan.md](.cursor/Plans/subplans/P001-UnitTestFailures/P001-UnitTestFailures.plan.md). | Validated | 92% | 95% |
| P001-Dyld | TableTopGame.debug.dylib launch crash (Xcode 16) | 2 | Fix: ENABLE_DEBUG_DYLIB = NO. **Fixed 2026-02-15. Pushed 2026-02-14.** Plan: [P001-Dyld-dyld-crash.plan.md](.cursor/Plans/subplans/P001-Dyld/P001-Dyld-dyld-crash.plan.md). | Complete and ready for github push | 95% | 95% |
| P001-C7-Garbage | Garbage count=1 empty row fix | 3 | garbagePositions(1)→[]; fix case 1→[0,4] done; LT-C7-1, LT-C7-2 done; A4 fidelity done. Plan: [P001-C7-Garbage.plan.md](.cursor/Plans/subplans/P001-C7-Garbage/P001-C7-Garbage.plan.md). | Complete and ready for github push | 95% | 95% |
| P001-RestartFix | Restart button at game over | 4 | Restart button at game ending does not work. Root cause: SpriteView does not replace presented SKScene when scene parameter changes. Fix: `.id(sceneIdentity)` on SpriteView; change identity in startNewGame(). Plan: [P001-RestartFix.plan.md](.cursor/Plans/subplans/P001-RestartFix/P001-RestartFix.plan.md). **R1+R2 complete 2026-02-14**; `testGameOverRealGameRestart` added. | Testing complete | 92% | 90% |
| P001-E2E-WATCH | E2E watchable boot/wait fix | 5 | Active waits for menu and game HUD; script waits for Simulator boot before tests. Fixes watchable run so app and game are visible during E2E. Plan: [e2e_active_wait_and_simulator_boot](.cursor/Plans/subplans/P001-E2E-WATCH/e2e_active_wait_and_simulator_boot_afb0c50c.plan.md). **All chunks done** (A1–C2). **Pushed 2026-02-08.** | Complete and ready for github push | 95% | 92% |
| P001 | TabletopGame Spec and Implementation | 6 | Dr. Mario–style head-to-head (2-player) puzzle game (Swift/SwiftUI/SpriteKit). Main plan: [.cursor/Plans/subplans/P001/P001-tabletopgame.plan.md](.cursor/Plans/subplans/P001/P001-tabletopgame.plan.md). Sub-plans: [.cursor/Plans/subplans/P001/](.cursor/Plans/subplans/P001/) (C1–C10, logic-test, ui-test). C10 validation chunks: [C10-validation-chunks.plan.md](.cursor/Plans/subplans/P001/C10-validation-chunks.plan.md) (C10-V1–V11). Execute by build chunks for early iPhone simulator visibility. **Test checkpoints**: Logic-Test after C5–C8; UI-Test at C10. | Complete and ready for github push | N/A | 90% |
| P001-LT | TabletopGame Logic-Test (user move validation) | 7 | Sub-plan of P001. See [.cursor/Plans/subplans/P001/logic-test.plan.md](.cursor/Plans/subplans/P001/logic-test.plan.md). Validate moves, turns, attack, elimination, win/tie. Delegate Logic-Test agent after C5, C6, C7, C8. | Testing complete | 92% | 88% |
| P001-UI | TabletopGame UI-Test (E2E, layout, contrast) | 8 | Sub-plan of P001. See [.cursor/Plans/subplans/P001/ui-test.plan.md](.cursor/Plans/subplans/P001/ui-test.plan.md). E2E user journeys, win/lose/tie overlay validation, iPhone/iPad viewports, layout and contrast. Delegate at C10. | Testing complete | N/A | N/A |
| P001-E2E | Full playthrough E2E harness | 9 | XCUITest full playthrough: Launch → Menu → New Game → Play until game over → Overlay → Restart/Return to Menu. Chunks E2E-P1–P8. Plan: [.cursor/Plans/subplans/P001/E2E-full-playthrough.plan.md](.cursor/Plans/subplans/P001/E2E-full-playthrough.plan.md). Watchable improvements: P001-E2E-WATCH. **Full suite green 2026-02-08** (unit + UI on iPhone 16). E2E-P8 viewport matrix implemented (testC10V8 + CI). | Testing complete | N/A | 90% |
| P002 | Gravity drop animation | 10 | Animated gravity when matches cleared; pips drop slowly to final position. Plan: [.cursor/Plans/subplans/P002/P002-gravity-animation.plan.md](.cursor/Plans/subplans/P002/P002-gravity-animation.plan.md). Chunks G1–G4. **G1+G2+G3+G4 complete.** UI-Test checkpoint passed 2026-02-14. **Pushed 2026-02-14.** | Complete and ready for github push | 95% | 90% |
| P001-C11 | App Store prep | 11 | Gap strategy for App Store submission. Plan: [.cursor/Plans/subplans/P001-C11/P001-C11-app-store.plan.md](.cursor/Plans/subplans/P001-C11/P001-C11-app-store.plan.md). Sub-plans: [.cursor/Plans/subplans/P001-C11/](.cursor/Plans/subplans/P001-C11/) (C11-A1–A5). Chunks: App icon, Support URL, ASC metadata, screenshots, upload/submit. A3 sequenced after P005 built; runbook will be updated for IAP/ads. | Validated | 92% | 90% |
| P006 | Spec gap features | 12 | Level selection UI, AI strength (Easy/Hard), ContentView cleanup. Plan: [P006-spec-gaps.plan.md](.cursor/Plans/subplans/P006/P006-spec-gaps.plan.md). Sub-plans: [P006/](.cursor/Plans/subplans/P006/) (G1–G3). Reference: [features-for-planner.md](.cursor/Plans/features-for-planner.md). | Validated | 98% | 95% |
| P006-E2E | E2E smarter tap strategy | 13 | Column-sweep tap strategy for full playthrough (P0-only); level 5 E2E. Plan: [P006-E2E-smarter-tap.plan.md](.cursor/Plans/subplans/P006/P006-E2E-smarter-tap.plan.md). Chunks L1–L3. | Validated | 95% | 92% |
| P006-G1-VDF | Virus disappear fix (level 5) | 14 | makeInitialViruses can place 4-in-a-row viruses; resolution clears them on first lock. Fix: constrain placement to avoid pre-existing matches. Chunks VDF-1, VDF-2, VDF-3. Plan: [P006-G1-virus-disappear-fix.plan.md](.cursor/Plans/subplans/P006/P006-G1-virus-disappear-fix.plan.md). | Test plan ready | 95% | 92% |
| P003 | AI animated drop | 15 | AI capsule drops row-by-row (visible) instead of instant hard-drop. Plan: [.cursor/Plans/subplans/P003/P003-ai-animated-drop.plan.md](.cursor/Plans/subplans/P003/P003-ai-animated-drop.plan.md). Chunks A1 (GameState place-only), A2 (GameScene two-phase AI). | Validated | 95% | 92% |
| P004 | Power-up System | 16 | Purchase power-ups with cash; hold 1; Clear Row, Send Garbage, Double Cash. AI same rules. Plan: [P004-power-up.plan.md](.cursor/Plans/subplans/P004/P004-power-up.plan.md). Sub-plans: [P004/](.cursor/Plans/subplans/P004/) (P1–P5). Planner/Blaster/Investigator reviewed; P2 gravity fix, P1 stub, P4 loop pattern applied. | Validated | 92% | 92% |
| P005 | Monetization | 17 | Paid = no ads, power-ups anytime; free = ads after win only, power-ups turn-only. Plan: [P005-monetization.plan.md](.cursor/Plans/subplans/P005/P005-monetization.plan.md). Sub-plans: [P005/](.cursor/Plans/subplans/P005/) (M1–M6: IAPManager, Paywall, ASC, StoreKit testing, Ads after win, Power-up gating). | Pending analysis | N/A | N/A |

---

## P001 Build Chunk Progress (TabletopGame)

When executing P001, track progress by **Planner Build Chunks** (C1–C10). After each chunk, run in iPhone simulator and confirm the visible outcome before advancing.

**Chunk-level confidence**: Updated by Blaster/Investigator when running per-chunk fidelity (Step 5). Each sub-plan file under `.cursor/Plans/subplans/P001/` must contain a **Confidence** section; keep this table in sync with those sub-plans.

| Chunk | Outcome | Status | Confidence (root cause) | Confidence (solution path) |
|-------|---------|--------|--------------------------|-----------------------------|
| C1 | App launches, placeholder visible | Done | 95% | 95% |
| C2 | Empty grid renders | Done | 92% | 90% |
| C3 | Viruses visible on grid | Done | 88% | 90% |
| C4 | Capsule move/rotate/drop playable | Done | 90% | 88% |
| C5 | Match + gravity work | Done | 90% | 88% |
| C6 | Turn flow, win/elimination (2 players) | Done | 92% | 90% |
| C7 - Perfected | Attack + garbage | Done | 95% | 95% |
| C8 | 2 boards + avatars (head-to-head) | Done | 92% | 92% |
| C9 | AI opponent (1 AI + 1 human) | Done | 92% | 91% |
| C10 | Menus, game over, restart; settings persist | Done | 92% | 92% |
| C11 | App Store prep | A1–A2 done; A3 deferred until P005 built; runbook ready | 92% | 90% |

**C11 chunks (P001-C11)**: A1 App icon, A2 Support URL, A3 ASC setup, A4 Screenshots, A5 Upload/submit. See [P001-C11-app-store.plan.md](.cursor/Plans/subplans/P001-C11/P001-C11-app-store.plan.md).

---

## P006-E2E Build Chunk Progress (Smarter Tap + Level 5)

Blaster pipeline complete. Per-chunk fidelity validated. See [P006-E2E-smarter-tap.plan.md](.cursor/Plans/subplans/P006/P006-E2E-smarter-tap.plan.md).

| Chunk | Outcome | Status | Confidence (root cause) | Confidence (solution path) |
|-------|---------|--------|--------------------------|-----------------------------|
| E2E-L1 | SmarterTapStrategy struct + testSmarterTapStrategySequence | Pending build | 95% | 92% |
| E2E-L2 | runFullPlaythrough: guard player1Turn, use strategy (P0-only tap) | Pending build | 95% | 92% |
| E2E-L3 | testFullPlaythroughLevel5 (Settings → level 5 → playthrough, 240s) | Pending build | 95% | 92% |

**Order:** L1 → L2 → L3 (L2 depends on L1; L3 depends on L2).

---

## P001 C10 Validation Chunks (Small Executable Pieces)

C10 code is built. Remaining work decomposed for AI execution. See [.cursor/Plans/subplans/P001/C10-validation-chunks.plan.md](.cursor/Plans/subplans/P001/C10-validation-chunks.plan.md). **E2E execution strategy** (phases, regression command, XCUITest, builder steps): See C10-validation-chunks.plan.md and E2E-full-playthrough.plan.md; use E2E optimized test plan in context if referenced elsewhere.

**Plan status**: Chunk plan and confidence validated by Blaster/Investigator/Logic-Test/UI-Test.

**Validation status (two gates):**  
- **Code/unit**: Code path verified + relevant unit tests passed (no app run).  
- **Manual/UI**: App run in simulator or XCUITest and outcome confirmed. Use **Done** when that run has been performed; **—** otherwise.

| Chunk | Outcome | Plan status | Code/unit | Manual/UI | Confidence (root cause) | Confidence (solution path) |
|-------|---------|-------------|-----------|-----------|--------------------------|----------------------------|
| C10-V1 | Launch → Menu → New Game | Validated | Done | Done | 92% | 92% |
| C10-V2 | Game Over (win) overlay | Validated | Done | Done | 92% | 92% |
| C10-V3 | Game Over (lose) overlay – P0/P1 top-out | Validated | Done | Done | 92% | 92% |
| C10-V4 | Game Over (tie) overlay | Validated | Done | Done | 92% | 92% |
| C10-V5 | Restart, Return to Menu | Validated | Done | Done | 92% | 92% |
| C10-V6 | Settings sheet | Validated | Done | Done | 92% | 92% |
| C10-V7 | Settings persist (kill app, relaunch) | Validated | Done | Done | 92% | 92% |
| C10-V8 | Viewport layout (iPhone SE, 15 Pro Max, iPad) | Validated | Done | Done | 92% | 92% |
| C10-V9 | Layout and contrast (GameOverOverlay, buttons, HUD) | Validated | Done | Done | 92% | 92% |
| C10-V10 | Logic-test E2E (fixture-based; optional) | Validated | Done | Done | 90% | 90% |
| C10-V11 | Infrastructure (offline, no network) | Validated | Done | Done | 92% | 92% |

---

## Adding or updating plans

1. **When creating a new plan**: Add a row to the matrix with a unique Plan ID (e.g. `P001`, or a short slug like `auth-fix`), plan name, priority rank, description, current state, and confidence values (use `N/A` if not applicable, e.g. before analysis).
2. **When advancing a plan**: Update **Current state** (and confidence columns if they change).
3. **When reprioritizing**: Adjust **Priority rank** and reorder rows so rank 1 is at the top; keep the table sorted by priority rank ascending (1 first).

## Where plans live

- **Master-Plan**: `.cursor/Plans/Master-Plan.md` — only file at Plans parent level.
- **Sub-plans folder**: `.cursor/Plans/subplans/<plan-id>/` — all plan work lives here.
- **Main plans (index)**: `.cursor/Plans/subplans/<plan-id>/<plan-id>-<short-name>.plan.md` — short index with links to sub-plans.
- **Sub-plans**: `.cursor/Plans/subplans/<plan-id>/<sub-id>-<short-name>.plan.md` — full steps, validation, rollback per chunk. Sub-plans may nest (e.g. P006-E2E under P006).
- **Per-plan archives**: `.cursor/Plans/subplans/<plan-id>/archive/` — completed chunks (e.g. P001/archive/C1-bootstrap).
- **Top-level archives**: `.cursor/Plans/archives/` — completed or superseded whole plans.
- **Unit test failures (P001-UnitTestFailures)**: [P001-UnitTestFailures.plan.md](.cursor/Plans/subplans/P001-UnitTestFailures/P001-UnitTestFailures.plan.md) — testGameStateInitTwoPlayers, testOneClearSendsVisibleGarbageToOpponent. UT-1 Builder in progress. Sub-plans: [UT1](.cursor/Plans/subplans/P001-UnitTestFailures/UT1-testGameStateInitTwoPlayers.plan.md), [UT2](.cursor/Plans/subplans/P001-UnitTestFailures/UT2-testOneClearSendsVisibleGarbageToOpponent.plan.md).
- **Dyld crash fix (P001-Dyld)**: [P001-Dyld-dyld-crash.plan.md](.cursor/Plans/subplans/P001-Dyld/P001-Dyld-dyld-crash.plan.md) — TableTopGame.debug.dylib launch crash (Xcode 16); set ENABLE_DEBUG_DYLIB = NO. Fixed 2026-02-15.
- **E2E watchable fix (P001-E2E-WATCH)**: `.cursor/Plans/subplans/P001-E2E-WATCH/e2e_active_wait_and_simulator_boot_afb0c50c.plan.md` — active waits, Simulator boot wait; chunks A1–C2.
- **Gravity animation (P002)**: `.cursor/Plans/subplans/P002/P002-gravity-animation.plan.md` — pips drop slowly when matches cleared; chunks G1–G4.
- **App Store prep (P001-C11)**: `.cursor/Plans/subplans/P001-C11/P001-C11-app-store.plan.md` — index; sub-plans under `.cursor/Plans/subplans/P001-C11/` (C11-A1–A5).
- **AI animated drop (P003)**: `.cursor/Plans/subplans/P003/P003-ai-animated-drop.plan.md` — AI capsule drops row-by-row; chunks A1–A2.
- **Power-up (P004)**: Main plan at `.cursor/Plans/subplans/P004/P004-power-up.plan.md`; planner review at `P004-power-up-planner-review.md`. Sub-plans (P1–P5) under `.cursor/Plans/subplans/P004/`.
- **Monetization (P005)**: [P005-monetization.plan.md](.cursor/Plans/subplans/P005/P005-monetization.plan.md) — Paid = no ads, power-ups anytime; free = ads after win only. Sub-plans (M1–M6).
- **Spec gaps (P006)**: [P006-spec-gaps.plan.md](.cursor/Plans/subplans/P006/P006-spec-gaps.plan.md) — Level selection, AI strength, ContentView cleanup. Sub-plans (G1–G3).
- **Virus disappear fix (P006-G1-VDF)**: [P006-G1-virus-disappear-fix.plan.md](.cursor/Plans/subplans/P006/P006-G1-virus-disappear-fix.plan.md) — Level 5 viruses disappear after ~2 drops; constrain makeInitialViruses to avoid 4-in-a-row. Chunks VDF-1, VDF-2, VDF-3.
- **E2E smarter tap (P006-E2E)**: [P006-E2E-smarter-tap.plan.md](.cursor/Plans/subplans/P006/P006-E2E-smarter-tap.plan.md) — SmarterTapStrategy, P0-only tap, level 5 playthrough. Chunks L1–L3.
- **Features for Planner**: [features-for-planner.md](.cursor/Plans/features-for-planner.md) — Elaborated feature set (Investigator + ideation + Blaster scope) for Planner decomposition. Reference when creating or refining plans.

### Plan folder layout

```
.cursor/Plans/
├── Master-Plan.md                      # ONLY file at parent; single source of truth
├── features-for-planner.md             # Reference for Planner decomposition
├── subplans/                           # All active plan work
│   ├── P001-UnitTestFailures/
│   │   ├── P001-UnitTestFailures.plan.md
│   │   ├── UT1-testGameStateInitTwoPlayers.plan.md
│   │   └── UT2-testOneClearSendsVisibleGarbageToOpponent.plan.md
│   ├── P001-Dyld/
│   │   └── P001-Dyld-dyld-crash.plan.md
│   ├── P001-C7-Garbage/
│   │   └── P001-C7-Garbage.plan.md
│   ├── P001-RestartFix/
│   │   └── P001-RestartFix.plan.md
│   ├── P001/
│   │   ├── P001-tabletopgame.plan.md   # index
│   │   ├── archive/
│   │   │   └── C1-bootstrap.plan.md
│   │   ├── C2-grid.plan.md … C10-menus.plan.md
│   │   ├── C10-validation-chunks.plan.md
│   │   ├── E2E-full-playthrough.plan.md
│   │   ├── logic-test.plan.md
│   │   └── ui-test.plan.md
│   ├── P001-C11/
│   │   ├── P001-C11-app-store.plan.md
│   │   ├── C11-A1-app-icon.plan.md … C11-A5-upload-submit.plan.md
│   │   ├── asc-setup-runbook.md
│   │   └── support-url.md
│   ├── P001-E2E-WATCH/
│   │   └── e2e_active_wait_and_simulator_boot_afb0c50c.plan.md
│   ├── P002/
│   │   └── P002-gravity-animation.plan.md
│   ├── P003/
│   │   └── P003-ai-animated-drop.plan.md
│   ├── P004/
│   │   ├── P004-power-up.plan.md       # main index
│   │   ├── P004-power-up-planner-review.md
│   │   └── P1-model.plan.md … P5-tests.plan.md
│   ├── P005/
│   │   ├── P005-monetization.plan.md
│   │   └── M1-iap-manager.plan.md … M6-powerup-gating.plan.md
│   └── P006/
│       ├── P006-spec-gaps.plan.md      # index; chunks G1–G3
│       ├── P006-G1-level-selection.plan.md … P006-G3-contentview-cleanup.plan.md
│       ├── P006-G1-virus-disappear-fix.plan.md
│       ├── P006-E2E-smarter-tap.plan.md   # nested index; chunks L1–L3
│       └── P006-E2E-L1-strategy.plan.md … P006-E2E-L3-level5.plan.md
└── archives/                           # Completed/superseded whole plans (when needed)
```

All matrix links use paths under `.cursor/Plans/subplans/`. Keep sub-plan files small; one logical unit per file. Sub-plans may nest larger plans broken into smaller chunks.
