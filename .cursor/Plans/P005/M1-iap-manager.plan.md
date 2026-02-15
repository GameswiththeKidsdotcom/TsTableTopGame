---
name: P005 M1 IAPManager
overview: Create IAPManager wrapping StoreKit 2; load products, purchase, restore; entitlement check via Transaction.currentEntitlements.
---

**Next hand off (cut & paste)**: **P005 M1 — IAPManager.** [M1-iap-manager.plan.md](.cursor/Plans/P005/M1-iap-manager.plan.md). Investigator: validate M1 for 90%+ confidence. Builder: create `IAPManager` wrapping StoreKit 2; `IAPProductIDs`; entitlement check via `Transaction.currentEntitlements`. Unit test with StoreKit Configuration (M4 provides config file).

---

## Outcome

`IAPManager` (ObservableObject) loads product, initiates purchase, restores purchases, and exposes `hasPremium: Bool` derived from `Transaction.currentEntitlements`. No UI in M1.

---

## Steps

1. **Create `IAPProductIDs.swift`**  
   - Path: `TableTopGame/Monetization/IAPProductIDs.swift`  
   - Define `enum IAPProductID { static let unlock = "com.tabletopgame.app.unlock" }`

2. **Create `IAPManager.swift`**  
   - Path: `TableTopGame/Monetization/IAPManager.swift`  
   - `@MainActor class IAPManager: ObservableObject`  
   - Properties: `@Published var products: [Product]`, `@Published var hasPremium: Bool`, `@Published var purchaseInProgress: Bool`  
   - Methods:  
     - `func loadProducts() async` — `Product.products(for: [IAPProductID.unlock])`  
     - `func purchase(_ product: Product) async throws` — `product.purchase()`  
     - `func restorePurchases() async` — `Transaction.sync()` then refresh `hasPremium`  
   - Entitlement: `Task { for await result in Transaction.currentEntitlements { if result.productID == IAPProductID.unlock { hasPremium = true } } }`  
   - On launch: call `loadProducts()` and check `Transaction.currentEntitlements`

3. **Add Monetization group to Xcode**  
   - Create group `Monetization` under TableTopGame  
   - Add `IAPProductIDs.swift`, `IAPManager.swift` to target

4. **Unit test (requires M4 StoreKit config)**  
   - Test: with StoreKit Configuration, `loadProducts()` returns product  
   - Test: `hasPremium` false initially; after simulated purchase, true  
   - Skip purchase in CI if config not present; or use StoreKit test configuration

---

## Technical Detail

- **StoreKit 2 APIs**: `Product.products(for:)`, `Product.purchase()`, `Transaction.currentEntitlements`, `Transaction.sync()`  
- **Persistence**: StoreKit 2 syncs `Transaction.currentEntitlements` across devices; no local persistence needed for entitlement  
- **Threading**: `@MainActor` for UI binding; async/await for StoreKit calls

---

## Validation

- Build succeeds; no new warnings  
- Unit test: loadProducts returns product (with StoreKit Configuration)  
- Manual: Run app, confirm no crash; IAPManager can be injected but not yet wired to UI

---

## Rollback

Remove `Monetization` group and files; remove from target. No other code depends on M1 until M2.

---

## Confidence

| | % |
|---|---|
| Confidence (root cause) | 88% |
| Confidence (solution path) | 88% |

**Note**: Entitlement derivation from `Transaction.currentEntitlements` is well-documented; solution path depends on M4 StoreKit Configuration for tests. Investigator to tighten if needed.
