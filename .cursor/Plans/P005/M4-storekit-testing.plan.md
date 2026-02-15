---
name: P005 M4 StoreKit Testing
overview: Add StoreKit Configuration file for local testing; unit tests for IAPManager entitlement logic.
---

**Next hand off (cut & paste)**: **P005 M4 — StoreKit Testing.** [M4-storekit-testing.plan.md](.cursor/Plans/P005/M4-storekit-testing.plan.md). Investigator: validate M4 for 90%+ confidence. Builder: Create StoreKit Configuration file; add entitlement unit tests. Logic-Test: confirm test coverage for entitlement and mocked purchase flow.

---

## Outcome

- StoreKit Configuration file with `com.tabletopgame.app.unlock` product  
- Xcode scheme uses this config when running tests  
- Unit tests for IAPManager: load products, entitlement check (with simulated purchase)

---

## Steps

1. **Create StoreKit Configuration file**  
   - File → New → File → StoreKit Configuration File  
   - Name: `Products.storekit`  
   - Add product: Non-Consumable, ID `com.tabletopgame.app.unlock`  
   - Price: $0.99 (or match ASC)

2. **Attach to scheme**  
   - Edit Scheme → Run → Options  
   - StoreKit Configuration: Select `Products.storekit`  
   - Enables local testing without ASC/Sandbox

3. **Unit tests for IAPManager**  
   - Path: `TableTopGameTests/IAPManagerTests.swift` (or add to existing test file)  
   - Test `loadProducts()`: with StoreKit config, products array non-empty  
   - Test entitlement: before purchase, `hasPremium` false; after `Product.purchase()` (simulated), `hasPremium` true  
   - Use `@MainActor` and async test helpers

4. **CI consideration**  
   - StoreKit Configuration works in CI (Xcode cloud, local); no network needed  
   - If config not used in CI, gate tests with `#if` or skip when products empty

5. **Delegate Logic-Test**  
   - Logic-Test agent: confirm entitlement state-machine coverage; purchase/restore flows; edge cases (network failure, cancel)

---

## Dependencies

- M1 IAPManager exists

**Recommendation**: Create M4 StoreKit config before or in parallel with M1 so M1 tests can run immediately.

---

## Technical Detail

- **StoreKit 2 testing**: Xcode 14+ supports StoreKit Configuration; simulated purchases in Simulator  
- **Test pattern**: `await MainActor.run { iapManager.loadProducts() }`; `expect(iapManager.products).notTo(beEmpty())`  
- **Simulated purchase**: Call `product.purchase()` in test; StoreKit Configuration fulfills it locally

---

## Validation

- Run unit tests: `IAPManagerTests` pass  
- Manual: Run app with config; purchase completes in Simulator without real payment  
- Logic-Test agent sign-off on coverage

---

## Rollback

Remove StoreKit config file; remove from scheme; delete or skip IAPManagerTests.

---

## Confidence

| | % |
|---|---|
| Confidence (root cause) | 90% |
| Confidence (solution path) | 90% |

**Note**: StoreKit Configuration is standard; test patterns documented. Investigator to validate CI compatibility.
