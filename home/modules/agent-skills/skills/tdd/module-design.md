# Module Design for Testability

From "A Philosophy of Software Design": a **deep module** has a small interface
hiding a lot of implementation. A **shallow module** has an interface nearly as
complex as what's behind it — avoid those, they cost you a test surface without
buying you any leverage.

When shaping a module, ask:

- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?

## Three habits that make tests natural

1. **Accept dependencies, don't create them**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **Return results, don't produce side effects**

   ```typescript
   // Testable
   function calculateDiscount(cart): Discount {}

   // Hard to test
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **Small surface area** — fewer methods means fewer tests; fewer params means
   simpler setup.
