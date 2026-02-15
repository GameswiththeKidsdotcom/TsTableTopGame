---
name: C11-A5 Upload and Submit
overview: Archive, validate, upload build; optional TestFlight; submit for App Review.
---

**Next hand off (cut & paste)**: **P001-C11 A5 — Upload and submit.** Xcode: Product > Archive; Validate; Distribute App > App Store Connect. Optional: Add internal TestFlight testers. Submit for App Review. Validate: build in ASC; submission in "In Review".

---

## Outcome

Build uploaded to App Store Connect and submitted for App Review.

## Steps

1. **Archive**: Xcode Product > Archive (Release, real device or generic device).
2. **Validate**: Organizer > Distribute App > App Store Connect > Upload; run validation.
3. **Upload**: Complete upload.
4. **Optional**: Add internal TestFlight testers; install on device; confirm app runs.
5. **Submit**: App Store Connect > Add build to version; fill Notes for Review if needed; Submit for Review.

## Prerequisites

- C11-A1 (icon), C11-A2 (support URL), C11-A3 (metadata), C11-A4 (screenshots) complete.
- Apple Developer Program active.

## Validation

- Build appears in TestFlight/App Store Connect.
- Submission status "In Review" or "Waiting for Review".

## Rollback

If validation fails: fix per Xcode/ASC error log. If rejected: address rejection reasons and resubmit.

## Confidence

| | % |
|---|---|
| Root cause | 88% |
| Solution path | 88% |
