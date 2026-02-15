---
name: C11-A3 App Store Connect Setup
overview: Create app record, metadata, privacy nutrition label, and age rating in App Store Connect.
---

**Next hand off (cut & paste)**: **P001-C11 A3 — App Store Connect setup.** In App Store Connect: create app record for `com.tabletopgame.app`; fill name, subtitle, description, keywords, category (Games > Puzzle); add Support URL; declare Privacy "Data Not Collected"; complete age rating questionnaire. Validate: no required-field warnings.

**Builder deliverable (2026-02-14)**: Runbook at [asc-setup-runbook.md](asc-setup-runbook.md) with copy-paste metadata, privacy selection, and age-rating answers. Human executes in App Store Connect (requires Developer account).

---

## Outcome

App Store Connect app record created with complete metadata, privacy, and age rating.

## Steps (App Store Connect)

See [asc-setup-runbook.md](asc-setup-runbook.md) for full copy-paste content. Summary:

1. **Create app**: New app, platform iOS, bundle ID `com.tabletopgame.app`.
2. **Metadata**: Name, subtitle (e.g. "Head-to-Head Puzzle Battle"), description (offline, 2-player/AI, single-device), keywords (comma-separated, no spaces), category Games > Puzzle.
3. **Support URL**: Use URL from C11-A2 (`https://github.com/GameswiththeKidsdotcom/TsTableTopGame`).
4. **Privacy Nutrition Label**: Select "Data Not Collected" (app uses only UserDefaults; no network, analytics, third-party SDKs).
5. **Age rating**: Complete questionnaire; expect 4+ for puzzle game (no violence, no UGC). Runbook has suggested answers.
6. Optional: Accessibility nutrition label if VoiceOver or other support is implemented.

## Validation

- All required fields show no warnings in App Store Connect.
- Privacy and age rating sections complete.

## Rollback

Edit metadata in App Store Connect; no code change.

## Confidence

| | % |
|---|---|
| Root cause | 90% |
| Solution path | 90% |
