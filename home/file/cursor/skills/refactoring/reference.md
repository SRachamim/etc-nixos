# Refactoring Reference — FP TypeScript Examples

Detailed before/after examples for key refactorings from the catalog.
All code uses fp-ts, `pipe`/`flow`, and immutable data.

> **Scope**: Transformation mechanics — step-by-step before/after refactorings. For *target architecture patterns* (domain modeling, workflows, DI, event sourcing, codecs, testing), see the **functional-typescript** skill's [reference.md](../functional-typescript/reference.md).

---

## Composing Functions

### Extract Function

**Before** — inline logic with a comment explaining intent:

```typescript
const processOrder = (order: Order): string => {
  // calculate total with discount
  const base = order.items.reduce((s, i) => s + i.price * i.qty, 0)
  const discount = base > 1000 ? base * 0.05 : 0
  const total = base - discount

  return `Order ${order.id}: $${total.toFixed(2)}`
}
```

**After** — extracted into a named pure function:

```typescript
const calculateTotal = (items: ReadonlyArray<LineItem>): number => {
  const base = items.reduce((s, i) => s + i.price * i.qty, 0)
  const discount = base > 1000 ? base * 0.05 : 0
  return base - discount
}

const processOrder = (order: Order): string =>
  `Order ${order.id}: $${calculateTotal(order.items).toFixed(2)}`
```

---

### Replace Temp with Pipeline

**Before** — chain of intermediate `const` bindings:

```typescript
const getPrice = (quantity: number, itemPrice: number): number => {
  const basePrice = quantity * itemPrice
  const discountFactor = basePrice > 1000 ? 0.95 : 0.98
  return basePrice * discountFactor
}
```

**After** — pipeline with named steps:

```typescript
import { pipe } from 'fp-ts/function'

const basePrice = (quantity: number, itemPrice: number): number =>
  quantity * itemPrice

const discountFactor = (base: number): number =>
  base > 1000 ? 0.95 : 0.98

const getPrice = (quantity: number, itemPrice: number): number =>
  pipe(
    basePrice(quantity, itemPrice),
    (base) => base * discountFactor(base)
  )
```

---

### Replace Loop with Pipeline

**Before** — imperative loop:

```typescript
const getOverdueNames = (invoices: Invoice[]): string[] => {
  const result: string[] = []
  for (const inv of invoices) {
    if (inv.dueDate < Date.now() && inv.balance > 0) {
      result.push(inv.customerName)
    }
  }
  return result
}
```

**After** — declarative pipeline:

```typescript
import { pipe } from 'fp-ts/function'
import * as A from 'fp-ts/ReadonlyArray'

const isOverdue = (inv: Invoice): boolean =>
  inv.dueDate < Date.now() && inv.balance > 0

const getOverdueNames = (invoices: ReadonlyArray<Invoice>): ReadonlyArray<string> =>
  pipe(invoices, A.filter(isOverdue), A.map((inv) => inv.customerName))
```

---

## Organizing Data

### Introduce Branded Type

**Before** — primitive obsession:

```typescript
const sendEmail = (to: string, subject: string, body: string): void => { /* ... */ }

sendEmail('not-an-email', 42 as any, '')  // no compile-time protection
```

**After** — branded types with smart constructor:

```typescript
import * as E from 'fp-ts/Either'

type Email = string & { readonly _brand: unique symbol }

const mkEmail = (s: string): E.Either<string, Email> =>
  /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s)
    ? E.right(s as Email)
    : E.left(`Invalid email: ${s}`)

const sendEmail = (to: Email, subject: string, body: string): void => { /* ... */ }
```

---

### Replace Record with Discriminated Union

**Before** — type code driving conditionals:

```typescript
interface Shape { kind: 'circle' | 'rect'; radius?: number; width?: number; height?: number }

const area = (s: Shape): number => {
  switch (s.kind) {
    case 'circle': return Math.PI * s.radius! ** 2
    case 'rect':   return s.width! * s.height!
  }
}
```

**After** — discriminated union with exhaustive fold:

```typescript
interface Circle { readonly _tag: 'Circle'; readonly radius: number }
interface Rect { readonly _tag: 'Rect'; readonly width: number; readonly height: number }

type Shape = Circle | Rect

const fold = <A>(onCircle: (r: number) => A, onRect: (w: number, h: number) => A) =>
  (shape: Shape): A => {
    switch (shape._tag) {
      case 'Circle': return onCircle(shape.radius)
      case 'Rect':   return onRect(shape.width, shape.height)
    }
  }

const area: (s: Shape) => number = fold(
  (r) => Math.PI * r ** 2,
  (w, h) => w * h
)
```

No optional fields, no `!` assertions, compiler-enforced exhaustiveness.

---

### Encapsulate with Optics

**Before** — deep immutable update is verbose:

```typescript
const updateCity = (company: Company, city: string): Company => ({
  ...company,
  address: {
    ...company.address,
    city,
  },
})
```

**After** — lens from `monocle-ts`:

```typescript
import { pipe } from 'fp-ts/function'
import * as L from 'monocle-ts/Lens'

const cityLens = pipe(L.id<Company>(), L.prop('address'), L.prop('city'))

const updateCity = (company: Company, city: string): Company =>
  pipe(cityLens, L.modify(() => city))(company)
```

Lenses compose: access the aggregate root, drill into nested value objects, update immutably. Verify lens laws (identity, retention, double-set) in property-based tests.

---

## Simplifying Conditional Expressions

### Replace Conditional with Fold

**Before** — switch on type code (OOP: Replace Conditional with Polymorphism):

```typescript
const getCharge = (movie: Movie, daysRented: number): number => {
  switch (movie.priceCode) {
    case 'regular':
      return 2 + (daysRented > 2 ? (daysRented - 2) * 1.5 : 0)
    case 'newRelease':
      return daysRented * 3
    case 'childrens':
      return 1.5 + (daysRented > 3 ? (daysRented - 3) * 1.5 : 0)
  }
}
```

**After** — discriminated union with fold:

```typescript
type PriceCode =
  | { readonly _tag: 'Regular' }
  | { readonly _tag: 'NewRelease' }
  | { readonly _tag: 'Childrens' }

const foldPriceCode = <A>(cases: {
  Regular: () => A
  NewRelease: () => A
  Childrens: () => A
}) => (pc: PriceCode): A => cases[pc._tag]()

const getCharge = (priceCode: PriceCode, daysRented: number): number =>
  pipe(
    priceCode,
    foldPriceCode({
      Regular:    () => 2 + (daysRented > 2 ? (daysRented - 2) * 1.5 : 0),
      NewRelease: () => daysRented * 3,
      Childrens:  () => 1.5 + (daysRented > 3 ? (daysRented - 3) * 1.5 : 0),
    })
  )
```

Adding a new price code variant causes a compile error everywhere `foldPriceCode` is used — no forgotten branches.

---

### Introduce Option

**Before** — null checks (OOP: Introduce Null Object):

```typescript
const getDiscount = (customer: Customer): number => {
  const membership = customer.membership
  if (membership === null || membership === undefined) {
    return 0
  }
  return membership.discountPercent
}
```

**After** — `Option` with combinators:

```typescript
import { pipe } from 'fp-ts/function'
import * as O from 'fp-ts/Option'

interface Customer { readonly membership: O.Option<Membership> }

const getDiscount = (customer: Customer): number =>
  pipe(
    customer.membership,
    O.map((m) => m.discountPercent),
    O.getOrElse(() => 0)
  )
```

---

### Replace Nested Conditional with Guard + Pipeline

**Before** — deeply nested:

```typescript
const processPayment = (payment: Payment): string => {
  if (payment.amount > 0) {
    if (payment.currency === 'USD') {
      if (payment.verified) {
        return `Processed $${payment.amount}`
      } else {
        return 'Unverified'
      }
    } else {
      return 'Unsupported currency'
    }
  } else {
    return 'Invalid amount'
  }
}
```

**After** — flat pipeline with `Either`:

```typescript
import { pipe } from 'fp-ts/function'
import * as E from 'fp-ts/Either'

const validateAmount = (p: Payment): E.Either<string, Payment> =>
  p.amount > 0 ? E.right(p) : E.left('Invalid amount')

const validateCurrency = (p: Payment): E.Either<string, Payment> =>
  p.currency === 'USD' ? E.right(p) : E.left('Unsupported currency')

const validateVerified = (p: Payment): E.Either<string, Payment> =>
  p.verified ? E.right(p) : E.left('Unverified')

const processPayment = (payment: Payment): string =>
  pipe(
    payment,
    validateAmount,
    E.flatMap(validateCurrency),
    E.flatMap(validateVerified),
    E.fold(
      (err) => err,
      (p) => `Processed $${p.amount}`
    )
  )
```

---

## Making Function Calls Simpler

### Introduce Parameter Object

**Before** — long parameter list:

```typescript
const createEvent = (
  title: string, start: Date, end: Date,
  location: string, organizer: string, isPublic: boolean
): Event => ({ /* ... */ })
```

**After** — single record parameter:

```typescript
interface CreateEventParams {
  readonly title: string
  readonly start: Date
  readonly end: Date
  readonly location: string
  readonly organizer: string
  readonly isPublic: boolean
}

const createEvent = (params: CreateEventParams): Event => ({ /* ... */ })
```

---

### Replace Error Code with Either

**Before** — error code or thrown exception:

```typescript
const divide = (a: number, b: number): number => {
  if (b === 0) throw new Error('Division by zero')
  return a / b
}
```

**After** — explicit `Either`:

```typescript
import * as E from 'fp-ts/Either'

const divide = (a: number, b: number): E.Either<string, number> =>
  b === 0 ? E.left('Division by zero') : E.right(a / b)
```

---

### Separate Query from Command

**Before** — mixed read + write:

```typescript
const withdrawAndGetBalance = (account: Account, amount: number): Account => {
  console.log(`Withdrawing ${amount}`)  // side effect
  return { ...account, balance: account.balance - amount }
}
```

**After** — pure query + effectful command:

```typescript
import * as IO from 'fp-ts/IO'

const debit = (account: Account, amount: number): Account =>
  ({ ...account, balance: account.balance - amount })

const logWithdrawal = (amount: number): IO.IO<void> =>
  () => console.log(`Withdrawing ${amount}`)
```

---

## Dealing with Generalization

### Form Higher-Order Function

**Before** — two functions with identical structure, different details (OOP: Template Method):

```typescript
const sumPositive = (ns: ReadonlyArray<number>): number =>
  ns.filter((n) => n > 0).reduce((a, b) => a + b, 0)

const sumEven = (ns: ReadonlyArray<number>): number =>
  ns.filter((n) => n % 2 === 0).reduce((a, b) => a + b, 0)
```

**After** — higher-order function parameterizing the varying step:

```typescript
const sumBy = (predicate: (n: number) => boolean) =>
  (ns: ReadonlyArray<number>): number =>
    pipe(ns, A.filter(predicate), A.reduce(0, (a, b) => a + b))

const sumPositive = sumBy((n) => n > 0)
const sumEven = sumBy((n) => n % 2 === 0)
```

---

### Widen Union (Extract Subclass → Add Variant)

**Before** — boolean flag driving behavior:

```typescript
interface Notification {
  readonly message: string
  readonly isUrgent: boolean
  readonly urgentRecipient?: string  // only set when isUrgent
}
```

**After** — discriminated union with a new variant:

```typescript
interface StandardNotification { readonly _tag: 'Standard'; readonly message: string }
interface UrgentNotification { readonly _tag: 'Urgent'; readonly message: string; readonly recipient: string }

type Notification = StandardNotification | UrgentNotification
```

No optional fields, no invalid states.

---

## Big Refactorings

### Separate Domain from Infrastructure

**Before** — mixed pure logic and side effects:

```typescript
const processOrder = async (orderId: string): Promise<void> => {
  const order = await db.findOrder(orderId)
  const total = order.items.reduce((s, i) => s + i.price * i.qty, 0)
  const discount = total > 100 ? total * 0.1 : 0
  await db.saveInvoice({ orderId, amount: total - discount })
  await emailService.send(order.email, `Your total: $${total - discount}`)
}
```

**After** — pure core + thin effectful shell:

```typescript
import { pipe } from 'fp-ts/function'
import * as TE from 'fp-ts/TaskEither'

// Pure domain
const calculateInvoiceAmount = (items: ReadonlyArray<LineItem>): number => {
  const total = items.reduce((s, i) => s + i.price * i.qty, 0)
  return total > 100 ? total * 0.9 : total
}

// Effectful shell
const processOrder = (orderId: string): TE.TaskEither<Error, void> =>
  pipe(
    findOrder(orderId),
    TE.map((order) => ({
      order,
      amount: calculateInvoiceAmount(order.items),
    })),
    TE.flatMap(({ order, amount }) =>
      pipe(
        saveInvoice({ orderId, amount }),
        TE.flatMap(() => sendEmail(order.email, `Your total: $${amount}`))
      )
    )
  )
```

The domain logic (`calculateInvoiceAmount`) is pure, testable without mocks, and reusable.

---

## Flexibility Refactorings (SDF-Derived)

### Extract Combinator

**Before** — repeated composition pattern across multiple functions:

```typescript
const withRetry = (task: TE.TaskEither<Error, Response>): TE.TaskEither<Error, Response> =>
  pipe(task, TE.orElse(() => task), TE.orElse(() => task))

const fetchUser = (id: string): TE.TaskEither<Error, Response> =>
  pipe(httpGet(`/users/${id}`), (t) => withRetry(t), TE.map(parseUser))

const fetchOrder = (id: string): TE.TaskEither<Error, Response> =>
  pipe(httpGet(`/orders/${id}`), (t) => withRetry(t), TE.map(parseOrder))

const fetchProduct = (id: string): TE.TaskEither<Error, Response> =>
  pipe(httpGet(`/products/${id}`), (t) => withRetry(t), TE.map(parseProduct))
```

**After** — combinator extracted; primitives and combinations share the same `Fetcher` type:

```typescript
type Fetcher<A> = (id: string) => TE.TaskEither<Error, A>

const withRetry = <A>(fetcher: Fetcher<A>): Fetcher<A> =>
  (id) => pipe(fetcher(id), TE.orElse(() => fetcher(id)), TE.orElse(() => fetcher(id)))

const withParse = <A>(parse: (r: Response) => A) =>
  (fetcher: Fetcher<Response>): Fetcher<A> =>
    (id) => pipe(fetcher(id), TE.map(parse))

const httpFetcher = (path: string): Fetcher<Response> =>
  (id) => httpGet(`${path}/${id}`)

const fetchUser: Fetcher<User> = pipe(httpFetcher('/users'), withRetry, withParse(parseUser))
const fetchOrder: Fetcher<Order> = pipe(httpFetcher('/orders'), withRetry, withParse(parseOrder))
const fetchProduct: Fetcher<Product> = pipe(httpFetcher('/products'), withRetry, withParse(parseProduct))
```

`withRetry` and `withParse` are combinators: they take a `Fetcher` and return a `Fetcher`. New combinators (e.g., `withCache`, `withTimeout`) compose the same way without touching existing code.

---

### Introduce Handler Registry

**Before** — closed dispatch requires editing the function for each new format:

```typescript
const serialize = (format: string, data: unknown): E.Either<string, string> => {
  switch (format) {
    case 'json': return E.right(JSON.stringify(data))
    case 'csv': return toCsv(data)
    default: return E.left(`Unknown format: ${format}`)
  }
}
```

**After** — open registry; new formats are added by registration:

```typescript
import { pipe } from 'fp-ts/function'
import * as RM from 'fp-ts/ReadonlyMap'
import * as Str from 'fp-ts/string'
import * as O from 'fp-ts/Option'
import * as E from 'fp-ts/Either'

type Serializer = (data: unknown) => E.Either<string, string>
type SerializerRegistry = ReadonlyMap<string, Serializer>

const register = (
  registry: SerializerRegistry,
  format: string,
  serializer: Serializer,
): SerializerRegistry => pipe(registry, RM.upsertAt(Str.Eq)(format, serializer))

const serialize = (registry: SerializerRegistry) =>
  (format: string, data: unknown): E.Either<string, string> =>
    pipe(
      registry,
      RM.lookup(Str.Eq)(format),
      O.fold(
        () => E.left(`Unknown format: ${format}`),
        (s) => s(data),
      ),
    )

// Adding XML never touches existing code:
const registry: SerializerRegistry = pipe(
  RM.empty,
  RM.upsertAt(Str.Eq)('json', (d) => E.right(JSON.stringify(d))),
  RM.upsertAt(Str.Eq)('csv', toCsv),
  RM.upsertAt(Str.Eq)('xml', toXml),
)
```

---

### Separate Base from Metadata Layer

**Before** — domain logic tangled with cross-cutting concerns:

```typescript
const transferFunds = (
  from: AccountId, to: AccountId, amount: Amount,
): TE.TaskEither<TransferError, TransferResult> =>
  pipe(
    TE.rightIO(() => { logger.info(`Transfer: ${from} -> ${to}, ${amount}`) }),
    TE.flatMap(() => TE.rightIO(() => { metrics.increment('transfer.started') })),
    TE.flatMap(() => getAccount(from)),
    TE.flatMap((source) => pipe(
      debit(source, amount),
      TE.fromEither,
      TE.map((debited) => { logger.debug('Debited', { account: from }); return debited }),
    )),
    TE.flatMap((debited) => getAccount(to)),
    TE.flatMap((target) => credit(target, amount)),
    TE.map((result) => { metrics.increment('transfer.completed'); return result }),
  )
```

**After** — pure base layer + independent metadata wrappers:

```typescript
import { pipe } from 'fp-ts/function'
import * as RTE from 'fp-ts/ReaderTaskEither'

interface LoggerDeps { readonly logger: { readonly info: (msg: string) => void } }
interface MetricsDeps { readonly metrics: { readonly increment: (key: string) => void } }

// Base layer — pure domain, no awareness of logging or metrics
const transferFunds = (
  from: AccountId, to: AccountId, amount: Amount,
): RTE.ReaderTaskEither<TransferDeps, TransferError, TransferResult> =>
  pipe(
    RTE.Do,
    RTE.bind('source', () => getAccount(from)),
    RTE.bind('debited', ({ source }) => RTE.fromEither(debit(source, amount))),
    RTE.bind('target', () => getAccount(to)),
    RTE.bind('credited', ({ target }) => credit(target, amount)),
    RTE.map(({ credited }) => credited),
  )

// Metadata layers — each independent, composable via RTE wrapping
const withLogging = <R extends LoggerDeps, E, A>(
  label: string,
) => (computation: RTE.ReaderTaskEither<R, E, A>): RTE.ReaderTaskEither<R, E, A> =>
  pipe(
    RTE.Do,
    RTE.bind('deps', () => RTE.ask<R>()),
    RTE.tap(({ deps }) => RTE.fromIO(() => deps.logger.info(`${label}: start`))),
    RTE.bind('result', () => computation),
    RTE.tap(({ deps }) => RTE.fromIO(() => deps.logger.info(`${label}: done`))),
    RTE.map(({ result }) => result),
  )

const withMetrics = <R extends MetricsDeps, E, A>(
  name: string,
) => (computation: RTE.ReaderTaskEither<R, E, A>): RTE.ReaderTaskEither<R, E, A> =>
  pipe(
    RTE.Do,
    RTE.bind('deps', () => RTE.ask<R>()),
    RTE.tap(({ deps }) => RTE.fromIO(() => deps.metrics.increment(`${name}.started`))),
    RTE.bind('result', () => computation),
    RTE.tap(({ deps }) => RTE.fromIO(() => deps.metrics.increment(`${name}.done`))),
    RTE.map(({ result }) => result),
  )

// Composition — layers wrap base without modifying it:
const transferWithMetadata = (from: AccountId, to: AccountId, amount: Amount) =>
  pipe(
    transferFunds(from, to, amount),
    withLogging('transfer'),
    withMetrics('transfer'),
  )
// Final type: RTE<TransferDeps & LoggerDeps & MetricsDeps, TransferError, TransferResult>
```

---

### Introduce Generate-and-Test

**Before** — generation and validation interleaved in a loop:

```typescript
const findAvailableSlot = (
  calendar: Calendar, duration: number, constraints: Constraints,
): TimeSlot | null => {
  for (const day of calendar.days) {
    for (const slot of day.slots) {
      if (slot.duration >= duration
        && !slot.isBooked
        && constraints.allowedDays.includes(day.name)
        && slot.start >= constraints.earliestStart) {
        return slot
      }
    }
  }
  return null
}
```

**After** — independent generator and evaluator:

```typescript
import { pipe } from 'fp-ts/function'
import * as RA from 'fp-ts/ReadonlyArray'
import * as O from 'fp-ts/Option'
import * as B from 'fp-ts/boolean'
import { Predicate } from 'fp-ts/Predicate'

interface SlotEntry { readonly day: Day; readonly slot: TimeSlot }

// Generator — produces all candidate slots, knows nothing about selection
const allSlots = (calendar: Calendar): ReadonlyArray<SlotEntry> =>
  pipe(
    calendar.days,
    RA.flatMap((day) => pipe(day.slots, RA.map((slot): SlotEntry => ({ day, slot })))),
  )

// Tester — independent composable predicates
type SlotRule = Predicate<SlotEntry>

const minDuration = (d: number): SlotRule => ({ slot }) => slot.duration >= d
const notBooked: SlotRule = ({ slot }) => !slot.isBooked
const onAllowedDay = (days: ReadonlyArray<string>): SlotRule =>
  ({ day }) => pipe(days, RA.elem(Str.Eq)(day.name))
const afterTime = (t: Time): SlotRule => ({ slot }) => slot.start >= t

const allOf = <A>(rules: ReadonlyArray<Predicate<A>>): Predicate<A> =>
  (a) => pipe(rules, RA.foldMap(B.MonoidAll)((rule) => rule(a)))

// Composition — generator and tester combined independently
const findAvailableSlot = (
  calendar: Calendar, duration: number, constraints: Constraints,
): O.Option<TimeSlot> =>
  pipe(
    allSlots(calendar),
    RA.findFirst(allOf([
      minDuration(duration),
      notBooked,
      onAllowedDay(constraints.allowedDays),
      afterTime(constraints.earliestStart),
    ])),
    O.map(({ slot }) => slot),
  )
```

Generator can be swapped (e.g., prioritized slot generation) without touching rules. Rules can be extended without touching the generator.
