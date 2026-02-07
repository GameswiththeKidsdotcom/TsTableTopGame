# C1 – Bootstrap (App Launches, Placeholder) — Archived

> **Archived**: Completed and validated 2025-02-07. Status: Done. Build succeeded; app launches with placeholder in iPhone simulator.

---

**Outcome**: App runs in iPhone simulator; user sees "TabletopGame" or placeholder. First visible result.

---

## Steps

| Step | Task | Validation |
|------|------|------------|
| 1 | Create `docs/SPEC.md` with: head-to-head (2-player) targeting (Option B), cash (1/virus, no chain bonus), coord system (origin top-left, row 0=spawn, cols 0–7), offline-only, virus count formula | SPEC exists |
| 2 | Create Xcode project (iOS App, SwiftUI); configure Debug/Release schemes | Build succeeds |
| 3 | Add ContentView with `Text("TabletopGame")` or minimal layout | Simulator shows app |
| 4 | (Optional) Add `.github/workflows/test.yml` for xcodebuild test | CI runs on push |

---

## Validation

- Build succeeds
- Run in iPhone simulator; user sees placeholder
- No network calls (offline-only)

---

## Rollback

Delete project; no external deps.
