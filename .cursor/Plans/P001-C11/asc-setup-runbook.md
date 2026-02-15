# App Store Connect Setup Runbook (C11-A3)

Runbook for creating the TableTopGame app record in App Store Connect. Execute at [appstoreconnect.apple.com](https://appstoreconnect.apple.com).

**Bundle ID**: `com.tabletopgame.app` (must exist in [developer.apple.com/account](https://developer.apple.com/account) → Certificates, Identifiers & Profiles → Identifiers)

**Support URL** (from C11-A2): `https://github.com/GameswiththeKidsdotcom/TsTableTopGame`

---

## 1. Create App

- **My Apps** → **+** → **New App**
- Platform: **iOS**
- Name: **TableTopGame**
- Primary Language: **English (U.S.)**
- Bundle ID: **com.tabletopgame.app** (select from dropdown; if missing, create in Developer portal first)
- SKU: `tabletopgame-1` (or any unique string)
- User Access: **Full Access** (or as needed)

---

## 2. App Information (metadata)

### Name
```
TableTopGame
```

### Subtitle (30 chars max)
```
Head-to-Head Puzzle Battle
```

### Description (4000 chars max)
```
TableTopGame is a Dr. Mario-style head-to-head puzzle game for two players or play against AI. Match colored pills to clear viruses and send garbage to your opponent.

• Offline, single-device play – no internet required
• 2-player local or vs AI
• Classic puzzle mechanics with attack and garbage rows
• Portrait and landscape support on iPhone and iPad

Perfect for quick matches with a friend or honing your skills against the AI.
```

### Keywords (100 chars max, comma-separated, NO spaces)
```
puzzle,dr mario,match,head-to-head,2 player,local,offline,AI,battle
```

### Category
- Primary: **Games** → **Puzzle**
- Secondary (optional): **Games** → **Strategy** or leave blank

---

## 3. Support URL

- **App Information** → **Support URL**
- Enter: `https://github.com/GameswiththeKidsdotcom/TsTableTopGame`

---

## 4. Privacy Nutrition Label

- **App Privacy** → **Get Started** (or edit existing)
- **Does your app collect data?** → **No, we do not collect data from this app**

This is correct: TableTopGame uses only `UserDefaults` for local settings; no network, analytics, or third-party SDKs.

If prompted for data types, declare **Data Not Collected** for all categories.

---

## 5. Age Rating

- **App Information** → **Age Rating** → **Edit**
- Complete the questionnaire. For TableTopGame (puzzle, no violence, no UGC, no in-app purchases):

| Question | Answer |
|---------|--------|
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Prolonged Graphic Violence | None |
| Profanity or Crude Humor | None |
| Mature/Suggestive Themes | None |
| Horror/Fear Themes | None |
| Medical/Treatment Information | None |
| Alcohol, Tobacco, Drug Use | None |
| Simulated Gambling | None |
| Unrestricted Web Access | No |
| Gambling | No |
| Contests | No |

**Expected rating**: 4+ (or equivalent in your region).

---

## 6. Version Info (first version)

When adding version 1.0:
- **Version**: 1.0
- **Copyright**: `2026 [Your Name or Company]`
- **Promotional Text** (170 chars, optional): Short hook for the app
- Reuse Name, Subtitle, Description, Keywords, Support URL from above

---

## Validation Checklist

- [ ] App record created
- [ ] Name, subtitle, description, keywords entered
- [ ] Category: Games > Puzzle
- [ ] Support URL set
- [ ] Privacy: Data Not Collected
- [ ] Age rating questionnaire complete
- [ ] No required-field warnings (yellow/red) in ASC

---

## Rollback

Edit or delete app record in App Store Connect. No code changes.
