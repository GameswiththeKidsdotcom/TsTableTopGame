---
name: C11-A1 App Icon
overview: Add 1024x1024 app icon to asset catalog. Blocks App Store submission without it.
---

**Next hand off (cut & paste)**: **P001-C11 A1 — App Icon.** Builder: Add 1024x1024 PNG to `TableTopGame/Assets.xcassets/AppIcon.appiconset/` and update Contents.json with `filename`. Validate: build succeeds; icon visible in Simulator.

**Validation (2026-02-14)**: Build succeeded. Icon compiled to AppIcon60x60@2x.png, AppIcon76x76@2x~ipad.png in app bundle. Full xcodebuild test passed 2026-02-14 (44 unit, 14 UI tests, exit 0, terminal 906460). C11-A1 complete.

---

## Outcome

1024x1024 universal app icon added to [AppIcon.appiconset](TableTopGame/Assets.xcassets/AppIcon.appiconset/Contents.json).

## Steps

1. Create or obtain a 1024x1024 PNG (square, no transparency, no rounded corners per Apple spec).
2. Add file to `TableTopGame/Assets.xcassets/AppIcon.appiconset/` (e.g. `AppIcon.png`).
3. Update `Contents.json`: add `"filename": "AppIcon.png"` to the image entry for `idiom: universal`, `size: 1024x1024`.

## Validation

- Build succeeds (`xcodebuild` or Xcode Product > Build).
- Run app in Simulator; icon appears on home screen.

## Rollback

Remove filename from Contents.json; delete added image file. App will use placeholder again.

## Confidence

| | % |
|---|---|
| Root cause (icon required) | 98% |
| Solution path | 95% |
