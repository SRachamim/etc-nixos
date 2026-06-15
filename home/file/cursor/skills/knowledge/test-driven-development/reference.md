# Test-Driven Development Reference -- fp-ts / io-ts / fast-check Examples

Concrete before/after examples for key TDD patterns from the SKILL.md catalog.
All code uses `fp-ts`, `io-ts`, `monocle-ts`, `fast-check`, and immutable data.

> **Scope**: *How to develop test-first* in functional TypeScript. For what good FP TypeScript looks like, see the **functional-typescript** skill's [reference.md](../functional-typescript/reference.md). For how to refactor, see the **refactoring** skill's [reference.md](../refactoring/reference.md).

---

## The TDD Cycle in Action -- Multi-Currency Money

Beck's running example, recast in pure functional TypeScript. We'll build a `Money` value object test-first.

### Step 1: Test List

```
- [ ] $5 * 2 = $10
- [ ] Money equality
- [ ] $5 + 10 CHF = $10 if CHF:USD = 2:1
- [ ] $5 + $5 = $10
```

### Step 2: Red -- First Failing Test

```typescript
import * as E from 'fp-ts/Either'
import { pipe } from 'fp-ts/function'
import * as Money from './Money'

test('$5 * 2 = $10', () => {
  const five = Money.dollar(5)
  const result = Money.times(2)(five)
  expect(result).toEqual(Money.dollar(10))
})
```

This does not compile -- `Money` module does not exist yet. That counts as red.

### Step 3: Green -- Fake It

```typescript
// Money.ts -- smallest thing that makes the test pass
export interface Money {
  readonly amount: number
  readonly currency: string
}

export const dollar = (amount: number): Money => ({ amount, currency: 'USD' })

export const times = (multiplier: number) => (m: Money): Money => ({ ...m, amount: 10 })
```

The `10` is a fake -- hard-coded. But the bar is green.

### Step 4: Refactor -- Remove Duplication

The `10` in the code duplicates `5 * 2` from the test. Replace the constant with an expression:

```typescript
export const times = (multiplier: number) => (m: Money): Money =>
  ({ ...m, amount: m.amount * multiplier })
```

Bar still green. Duplication eliminated. Cycle complete.

### Step 5: Next Test -- Equality (Triangulation)

```typescript
test('money equality', () => {
  expect(Money.equals(Money.dollar(5), Money.dollar(5))).toBe(true)
  expect(Money.equals(Money.dollar(5), Money.dollar(6))).toBe(false)
  expect(Money.equals(Money.dollar(5), Money.franc(5))).toBe(false)
})
```

We need two examples (5≡5, 5≢6) to triangulate toward comparing amounts, and a third to compare currencies:

```typescript
export const equals = (a: Money, b: Money): boolean =>
  a.amount === b.amount && a.currency === b.currency
```

### Step 6: Mixed Currency -- Expression Metaphor

Beck's key insight: model the sum of two monies as an `Expression` tree, reduced to a single currency by a `Bank`. In fp-ts:

```typescript
// Expression.ts
import * as E from 'fp-ts/Either'

export type Expression = Money | Sum

export interface Sum {
  readonly _tag: 'Sum'
  readonly augend: Expression
  readonly addend: Expression
}

export const sum = (augend: Expression, addend: Expression): Sum =>
  ({ _tag: 'Sum', augend, addend })
```

```typescript
// Bank.ts
import { pipe } from 'fp-ts/function'
import * as E from 'fp-ts/Either'

interface Rate { readonly from: string; readonly to: string; readonly factor: number }

type Bank = ReadonlyArray<Rate>

const findRate = (bank: Bank, from: string, to: string): number =>
  from === to
    ? 1
    : pipe(
        bank,
        RA.findFirst((r) => r.from === from && r.to === to),
        O.map((r) => r.factor),
        O.getOrElse(() => 1),
      )

export const reduce = (bank: Bank, to: string) => (expr: Expression): Money => {
  switch (expr._tag) {
    case 'Sum': {
      const a = reduce(bank, to)(expr.augend)
      const b = reduce(bank, to)(expr.addend)
      return { _tag: 'Money', amount: a.amount + b.amount, currency: to }
    }
    default:
      return { ...expr, amount: expr.amount / findRate(bank, expr.currency, to), currency: to }
  }
}
```

Test:

```typescript
test('$5 + 10 CHF = $10 if CHF:USD = 2:1', () => {
  const bank: Bank = [{ from: 'CHF', to: 'USD', factor: 2 }]
  const expr = Expression.sum(Money.dollar(5), Money.franc(10))
  const result = Bank.reduce(bank, 'USD')(expr)
  expect(result).toEqual(Money.dollar(10))
})
```

---

## Fake It -- Gradually Replacing Constants

**Red** -- we want to validate an order and collect all errors:

```typescript
test('validates all fields and collects errors', () => {
  const raw = { orderId: '', customerName: '', items: [] }
  const result = validateOrder(raw)
  expect(E.isLeft(result)).toBe(true)
  if (E.isLeft(result)) {
    expect(result.left).toHaveLength(3)
  }
})
```

**Green (Fake It)**:

```typescript
const validateOrder = (_raw: RawOrder): E.Either<ReadonlyArray<ValidationError>, ValidatedOrder> =>
  E.left([
    { field: 'orderId', message: 'required' },
    { field: 'customerName', message: 'required' },
    { field: 'items', message: 'required' },
  ])
```

**Refactor** -- replace hard-coded errors with real validation, using applicative validation:

```typescript
import { sequenceS } from 'fp-ts/Apply'
import * as RA from 'fp-ts/ReadonlyArray'

type VE = ReadonlyArray<ValidationError>
const V = E.getApplicativeValidation(RA.getSemigroup<ValidationError>())
const apS = sequenceS(V)

const validateOrderId = (s: string): E.Either<VE, OrderId> =>
  s.length > 0 ? pipe(OrderId.create(s), E.mapLeft((e) => [{ field: 'orderId', message: e }])) : E.left([{ field: 'orderId', message: 'required' }])

const validateCustomerName = (s: string): E.Either<VE, string> =>
  s.length > 0 ? E.right(s) : E.left([{ field: 'customerName', message: 'required' }])

const validateItems = (items: ReadonlyArray<RawItem>): E.Either<VE, ReadonlyArray<ValidatedItem>> =>
  items.length > 0
    ? pipe(items, RA.traverse(V)(validateItem))
    : E.left([{ field: 'items', message: 'required' }])

const validateOrder = (raw: RawOrder): E.Either<VE, ValidatedOrder> =>
  pipe(
    apS({
      orderId: validateOrderId(raw.orderId),
      customerName: validateCustomerName(raw.customerName),
      items: validateItems(raw.items),
    }),
    E.map(({ orderId, customerName, items }): ValidatedOrder => ({
      _tag: 'ValidatedOrder',
      orderId,
      customerName,
      items,
    })),
  )
```

Bar is green, duplication eliminated, test unchanged.

---

## Triangulation -- Discovering the Right Abstraction

We are building an `Eq` instance for a domain type. We start with Fake It:

```typescript
test('same order ids are equal', () => {
  const a = OrderId.unsafeCreate('ORD-001')
  const b = OrderId.unsafeCreate('ORD-001')
  expect(OrderId.Eq.equals(a, b)).toBe(true)
})
```

```typescript
// Fake It
export const Eq: Eq.Eq<OrderId> = { equals: () => true }
```

Now we triangulate with a second example:

```typescript
test('different order ids are not equal', () => {
  const a = OrderId.unsafeCreate('ORD-001')
  const b = OrderId.unsafeCreate('ORD-002')
  expect(OrderId.Eq.equals(a, b)).toBe(false)
})
```

Forced to generalise:

```typescript
export const Eq: Eq.Eq<OrderId> = Str.Eq
```

---

## One to Many

Beck's pattern: implement for a single value, then generalise to a collection.

**Single**:

```typescript
test('price one item', () => {
  const item: ValidatedItem = { productCode: 'WIDGET', quantity: UnitQuantity.unsafeCreate(3) }
  const result = priceItem(catalog)(item)
  expect(result).toEqual(E.right({ ...item, linePrice: 3 * 10 }))
})

const priceItem = (catalog: Catalog) => (item: ValidatedItem): E.Either<PricingError, PricedItem> =>
  pipe(
    catalog.lookup(item.productCode),
    O.map((unitPrice) => ({ ...item, linePrice: UnitQuantity.value(item.quantity) * unitPrice })),
    E.fromOption(() => ({ _tag: 'ProductNotFound' as const, code: item.productCode })),
  )
```

**Many** -- scale up with `traverse`:

```typescript
test('price all items', () => {
  const items: ReadonlyArray<ValidatedItem> = [item1, item2]
  const result = priceItems(catalog)(items)
  expect(E.isRight(result)).toBe(true)
})

const priceItems = (catalog: Catalog) => (items: ReadonlyArray<ValidatedItem>): E.Either<PricingError, ReadonlyArray<PricedItem>> =>
  pipe(items, RA.traverse(E.Applicative)(priceItem(catalog)))
```

---

## Custom Interpreter (Mock Object)

No mocking library needed. The algebra/interpreter split from the **functional-typescript** skill gives us the test boundary naturally.

**Algebra**:

```typescript
interface OrderRepository {
  readonly findOrder: (id: OrderId) => TE.TaskEither<RepoError, Order>
  readonly saveOrder: (order: Order) => TE.TaskEither<RepoError, void>
}
```

**Production interpreter** calls the real database.

**Test interpreter** returns canned values:

```typescript
const testRepo: OrderRepository = {
  findOrder: (_id) => TE.right(sampleOrder),
  saveOrder: (_order) => TE.right(undefined),
}
```

**Test**:

```typescript
test('cancelling an open order produces CancelledOrder', async () => {
  const result = await pipe(
    cancelOrder(OrderId.unsafeCreate('ORD-001')),
    RTE.provideReader({ orderRepo: testRepo }),
  )()
  expect(result).toEqual(E.right(expect.objectContaining({ _tag: 'CancelledOrder' })))
})
```

### Failing Interpreter (Crash Test Dummy)

Override one function to simulate failure:

```typescript
const failingRepo: OrderRepository = {
  ...testRepo,
  saveOrder: () => TE.left({ _tag: 'ConnectionError' as const, message: 'timeout' }),
}

test('save failure propagates as workflow error', async () => {
  const result = await pipe(
    cancelOrder(OrderId.unsafeCreate('ORD-001')),
    RTE.provideReader({ orderRepo: failingRepo }),
  )()
  expect(E.isLeft(result)).toBe(true)
})
```

---

## Self Shunt

The test module itself provides the dependency interface. Useful when you need to observe calls:

```typescript
test('workflow calls validate then price in order', async () => {
  const log: string[] = []

  const deps: PlaceOrderDeps = {
    validateOrder: (o) => { log.push('validate'); return E.right(validatedOrder) },
    priceOrder: (o) => { log.push('price'); return TE.right(pricedOrder) },
    createEvents: (o) => { log.push('events'); return [orderPlacedEvent] },
  }

  await pipe(placeOrder(command)(deps))()
  expect(log).toEqual(['validate', 'price', 'events'])
})
```

---

## Log String -- Verifying Sequence

Beck's Log String pattern, adapted for fp-ts pipelines:

```typescript
test('lifecycle transitions follow the protocol', () => {
  const log: string[] = []

  const trackingPay: PayOrder = (order) => {
    log.push(`pay:${order._tag}`)
    return TE.right({ ...order, _tag: 'PaidOrder' as const, paymentRef: 'REF-1' as PaymentRef })
  }

  const trackingShip: ShipOrder = (order) => {
    log.push(`ship:${order._tag}`)
    return TE.right({ ...order, _tag: 'ShippedOrder' as const, trackingCode: 'TRK-1' as TrackingCode })
  }

  // Run the pipeline
  await pipe(
    placedOrder,
    trackingPay,
    TE.flatMap(trackingShip),
  )()

  expect(log).toEqual(['pay:PlacedOrder', 'ship:PaidOrder'])
})
```

---

## Property-Based Testing -- Codec Round-Trip

**Law**: `decode(encode(a)) ≡ Right(a)` for all valid `a`.

```typescript
import * as fc from 'fast-check'
import * as t from 'io-ts'
import { pipe } from 'fp-ts/function'
import * as E from 'fp-ts/Either'

const OrderIdCodec = t.brand(
  t.string,
  (s): s is t.Branded<string, { readonly OrderId: unique symbol }> => s.length > 0 && s.length <= 36,
  'OrderId',
)

const orderIdArb = fc
  .stringOf(fc.alphaNumeric(), { minLength: 1, maxLength: 36 })
  .filter((s) => OrderIdCodec.is(s))

test('OrderId codec round-trips', () => {
  fc.assert(
    fc.property(orderIdArb, (id) => {
      const encoded = OrderIdCodec.encode(id)
      const decoded = OrderIdCodec.decode(encoded)
      expect(decoded).toEqual(E.right(id))
    }),
  )
})
```

---

## Property-Based Testing -- Domain Invariant

**Invariant**: crediting then debiting the same amount preserves the balance.

```typescript
import * as fc from 'fast-check'

const positiveAmountArb = fc.integer({ min: 1, max: 100_000 }).map((n) => n / 100)

test('credit then debit of equal amount is identity on balance', () => {
  fc.assert(
    fc.property(positiveAmountArb, (amount) => {
      const account = makeTestAccount({ balance: 1000 })

      const result = pipe(
        account,
        credit(amount),
        E.flatMap(debit(amount)),
      )

      expect(pipe(result, E.map((a) => a.balance))).toEqual(E.right(account.balance))
    }),
  )
})
```

---

## Property-Based Testing -- Monoid Laws

```typescript
import * as fc from 'fast-check'
import { pipe } from 'fp-ts/function'

const mergeMonoid: Monoid<MergedResult> = { /* ... */ }
const mergedResultArb: fc.Arbitrary<MergedResult> = /* ... */

test('MergedResult monoid: left identity', () => {
  fc.assert(
    fc.property(mergedResultArb, (a) => {
      expect(mergeMonoid.concat(mergeMonoid.empty, a)).toEqual(a)
    }),
  )
})

test('MergedResult monoid: right identity', () => {
  fc.assert(
    fc.property(mergedResultArb, (a) => {
      expect(mergeMonoid.concat(a, mergeMonoid.empty)).toEqual(a)
    }),
  )
})

test('MergedResult monoid: associativity', () => {
  fc.assert(
    fc.property(mergedResultArb, mergedResultArb, mergedResultArb, (a, b, c) => {
      expect(mergeMonoid.concat(mergeMonoid.concat(a, b), c)).toEqual(
        mergeMonoid.concat(a, mergeMonoid.concat(b, c)),
      )
    }),
  )
})
```

---

## Property-Based Testing -- Lens Laws

```typescript
import * as fc from 'fast-check'
import * as L from 'monocle-ts/Lens'

const balanceLens = pipe(L.id<Account>(), L.prop('balance'))

const accountArb: fc.Arbitrary<Account> = /* ... */
const balanceArb: fc.Arbitrary<number> = fc.double({ min: 0, max: 1_000_000, noNaN: true })

test('lens get-set: setting what you get changes nothing', () => {
  fc.assert(
    fc.property(accountArb, (account) => {
      const got = balanceLens.get(account)
      expect(balanceLens.set(got)(account)).toEqual(account)
    }),
  )
})

test('lens set-get: you get what you set', () => {
  fc.assert(
    fc.property(accountArb, balanceArb, (account, newBalance) => {
      expect(balanceLens.get(balanceLens.set(newBalance)(account))).toEqual(newBalance)
    }),
  )
})

test('lens set-set: setting twice keeps last', () => {
  fc.assert(
    fc.property(accountArb, balanceArb, balanceArb, (account, b1, b2) => {
      expect(balanceLens.set(b2)(balanceLens.set(b1)(account))).toEqual(balanceLens.set(b2)(account))
    }),
  )
})
```

---

## Degeneracy -- Cross-Verification with Properties

Two independent implementations of the same computation should agree:

```typescript
test('line-item total equals fold total for all valid orders', () => {
  fc.assert(
    fc.property(pricedOrderArb, (order) => {
      const byLineItems = pipe(
        order.items,
        RA.foldMap(N.MonoidSum)((item) => item.linePrice),
      )
      const byAmountToBill = order.amountToBill

      expect(byLineItems).toBeCloseTo(byAmountToBill, 2)
    }),
  )
})
```

---

## Evident Data -- Making Intent Visible

**Before** -- magic number hides intent:

```typescript
test('standard commission is deducted', () => {
  const result = applyCommission(Money.dollar(100), standardRate)
  expect(result).toEqual(Money.dollar(98.5))
})
```

**After** -- computation visible:

```typescript
test('standard commission is deducted', () => {
  const principal = 100
  const commissionRate = 0.015
  const result = applyCommission(Money.dollar(principal), commissionRate)
  expect(result).toEqual(Money.dollar(principal * (1 - commissionRate)))
})
```

---

## Child Test -- Breaking Down a Too-Big Test

We want to test a full order workflow but it requires too many changes at once:

```typescript
// TOO BIG -- skip this for now
test.skip('full workflow: command → events', async () => { /* ... */ })
```

Write child tests for each pipeline step individually:

```typescript
test('validate rejects empty order id', () => {
  const raw = { ...validRawOrder, orderId: '' }
  expect(E.isLeft(validateOrder(raw))).toBe(true)
})

test('price looks up unit price from catalog', () => {
  const result = priceItem(testCatalog)(validatedItem)
  expect(result).toEqual(E.right(expect.objectContaining({ linePrice: 30 })))
})

test('create events produces OrderPlaced', () => {
  const events = createEvents(pricedOrder)
  expect(events).toContainEqual(expect.objectContaining({ _tag: 'OrderPlaced' }))
})
```

Once all child tests pass, reintroduce the full workflow test -- it should pass with minimal or no additional changes.

---

## Regression Test -- Defect-Driven

A bug report says: "Orders with zero-quantity items are accepted."

Write the smallest failing test:

```typescript
test('zero quantity is rejected', () => {
  const result = UnitQuantity.create(0)
  expect(result).toEqual(E.left('UnitQuantity must be >= 1'))
})
```

Fix the smart constructor:

```typescript
export const create = (n: number): E.Either<string, UnitQuantity> =>
  n < 1
    ? E.left('UnitQuantity must be >= 1')
    : n > 1000
      ? E.left('UnitQuantity must be <= 1000')
      : E.right(n as UnitQuantity)
```

Then add a property to prevent recurrence:

```typescript
test('no non-positive quantity is accepted', () => {
  fc.assert(
    fc.property(fc.integer({ min: -1000, max: 0 }), (n) => {
      expect(E.isLeft(UnitQuantity.create(n))).toBe(true)
    }),
  )
})
```
