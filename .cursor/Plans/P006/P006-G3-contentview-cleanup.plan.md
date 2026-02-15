---
name: P006-G3 ContentView Cleanup
overview: Document or remove legacy ContentView; ensure single path via GameView.
todos: []
isProject: false
---

# P006-G3 – ContentView Cleanup

**Next hand off (cut & paste)**: **P006 G3 — ContentView cleanup.** Builder: Add `// MARK: - Preview only; production uses GameView via RootView` to ContentView. Ensure GameView has `#Preview { GameView(onRestart: {}, onReturnToMenu: {}) }`. Optionally remove ContentView if no longer needed. Verify E2E and build pass. Plan: [P006-G3-contentview-cleanup.plan.md](P006-G3-contentview-cleanup.plan.md).

---

## Outcome

ContentView is either removed or clearly documented as preview-only. No functional change; single production path via RootView → GameView.

---

## Steps

| Step | Task | Validation |
|------|------|-------------|
| 1 | Add documentation comment to ContentView clarifying preview-only use | Code review |
| 2 | Ensure GameView has its own #Preview (already has `#Preview { GameView(...) }`) | Preview renders |
| 3 | Optional: Delete ContentView if no references remain | Build passes; grep ContentView |
| 4 | Run E2E; confirm no regression | xcodebuild test |

---

## Integration points

| Component | Change |
|-----------|--------|
| ContentView | Comment only (or delete) |
| GameView | Verify #Preview exists |

**Note:** TableTopGameApp → RootView; ContentView is not in production path. It may be referenced by SwiftUI previews elsewhere; verify before delete.

---

## Rollback

Restore ContentView from git if delete caused issues.

---

## Confidence

| | Value | Note |
|---|-------|------|
| **Confidence (root cause)** | 95% | ContentView is duplicate path |
| **Confidence (solution path)** | 95% | Document or remove; low risk |
