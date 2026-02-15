---
name: P005 M3 ASC Products
overview: Create IAP product in App Store Connect; update age rating runbook.
---

**Next hand off (cut & paste)**: **P005 M3 — ASC Products.** [M3-asc-products.plan.md](.cursor/Plans/P005/M3-asc-products.plan.md). Human/Builder: Create IAP product in App Store Connect (In-App Purchases); update asc-setup-runbook.md age rating to In-App Purchases = Yes.

---

## Outcome

- Non-consumable IAP product `com.tabletopgame.app.unlock` exists in ASC and is attached to the app  
- Age rating questionnaire reflects In-App Purchases = Yes  
- Runbook updated for future submissions

---

## Steps

1. **App Store Connect — In-App Purchases**  
   - My Apps → TableTopGame → Features → In-App Purchases  
   - Create: Non-Consumable  
   - Reference Name: "Remove Ads & Unlock Power-ups" (or "Premium Unlock")  
   - Product ID: `com.tabletopgame.app.unlock` (must match IAPProductIDs)  
   - Price: Set tier (e.g. $0.99)  
   - Attach to app version when submitting

2. **Paid Apps & In-App Purchases agreement**  
   - Ensure Banking and Tax forms complete in App Store Connect  
   - Required before IAP can go live

3. **Update asc-setup-runbook.md**  
   - Path: [asc-setup-runbook.md](.cursor/Plans/P001-C11/asc-setup-runbook.md)  
   - Age rating section: Change "no in-app purchases" to "In-App Purchases: Yes"  
   - Add row to questionnaire table if needed

4. **Update app version in ASC**  
   - When submitting build: add IAP to version; ensure product is "Ready to Submit"

---

## Dependencies

- M1, M2 code complete (product ID must exist in ASC for Sandbox testing)  
- Apple Developer Program active; Paid Apps agreement signed

---

## Validation

- Product appears in ASC under app  
- Sandbox tester can complete purchase on device  
- Runbook diff shows age rating update

---

## Rollback

- Deactivate or delete product in ASC (cannot delete if used in release)  
- Revert runbook change; resubmit age rating as "No" if removing IAP

---

## Confidence

| | % |
|---|---|
| Confidence (root cause) | 95% |
| Confidence (solution path) | 92% |

**Note**: ASC workflow is documented; human execution. Builder can update runbook only.
