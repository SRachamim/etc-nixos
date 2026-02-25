# Functional TypeScript Reference — fp-ts Examples

Concrete before/after examples for key patterns from the SKILL.md catalog.
All code uses `fp-ts`, `io-ts`, `monocle-ts`, and immutable data.

> **Scope**: Target architecture patterns — what good FP TypeScript looks like (domain modeling, workflows, DI, event sourcing, codecs, testing). For *transformation mechanics* (how to refactor from bad to good), see the **refactoring** skill's [reference.md](../refactoring/reference.md).

---

## Type-Driven Domain Modeling

### Branded Simple Values

Primitives like `string` and `number` should never be used raw for domain concepts.

**Before** — primitive obsession, nothing prevents mixing up ids:

```typescript
const processOrder = (orderId: string, customerId: string): void => { /* ... */ }

processOrder(customerId, orderId) // args swapped — compiles fine, bug at runtime
```

**After** — branded types with smart constructors:

```typescript
// OrderId.ts — one module per branded type
import * as E from 'fp-ts/Either'

export type OrderId = string & { readonly _brand: unique symbol }

export const create = (s: string): E.Either<string, OrderId> =>
  s.length > 0 ? E.right(s as OrderId) : E.left('OrderId cannot be empty')

// CustomerId.ts follows the same pattern
```

```typescript
// Usage — consumers namespace via import
import * as OrderId from './OrderId'
import * as CustomerId from './CustomerId'

const processOrder = (orderId: OrderId.OrderId, customerId: CustomerId.CustomerId): void => { /* ... */ }

// processOrder(customerId, orderId) — now a compile error
```

---

### Smart Constructors for Constrained Types

From Wlaschin's `UnitQuantity` and Ghosh's smart constructor idiom: never allow direct construction of constrained values.

**Before** — unconstrained, invariants checked ad-hoc:

```typescript
type UnitQuantity = number

const priceOrder = (qty: UnitQuantity): number => {
  if (qty < 1 || qty > 1000) throw new Error('Invalid quantity')
  return qty * 5.0
}
```

**After** — smart constructor guarantees the invariant once, trusted everywhere else:

```typescript
// UnitQuantity.ts
import * as E from 'fp-ts/Either'

export type UnitQuantity = number & { readonly _brand: unique symbol }

export const create = (n: number): E.Either<string, UnitQuantity> =>
  n < 1
    ? E.left('UnitQuantity must be >= 1')
    : n > 1000
      ? E.left('UnitQuantity must be <= 1000')
      : E.right(n as UnitQuantity)

export const value = (qty: UnitQuantity): number => qty
```

```typescript
// Usage
import * as UnitQuantity from './UnitQuantity'

const priceOrder = (qty: UnitQuantity.UnitQuantity): number => UnitQuantity.value(qty) * 5.0
```

---

### Make Illegal States Unrepresentable — Lifecycle States

From Wlaschin: model each stage of an order as a separate type, not flags.

**Before** — optional fields and booleans encode state:

```typescript
interface Order {
  readonly id: string
  readonly items: ReadonlyArray<OrderLine>
  readonly isValidated: boolean
  readonly validatedAt?: Date
  readonly totalPrice?: number
  readonly pricedAt?: Date
}
```

**After** — distinct types per lifecycle state:

```typescript
interface UnvalidatedOrder {
  readonly _tag: 'UnvalidatedOrder'
  readonly id: OrderId
  readonly items: ReadonlyArray<UnvalidatedOrderLine>
}

interface ValidatedOrder {
  readonly _tag: 'ValidatedOrder'
  readonly id: OrderId
  readonly items: ReadonlyArray<ValidatedOrderLine>
  readonly validatedAt: Date
}

interface PricedOrder {
  readonly _tag: 'PricedOrder'
  readonly id: OrderId
  readonly items: ReadonlyArray<PricedOrderLine>
  readonly amountToBill: BillingAmount
  readonly pricedAt: Date
}
```

Each type guarantees: an `UnvalidatedOrder` has no price, a `PricedOrder` always has a price. No invalid combinations exist.

---

### Make Illegal States Unrepresentable — Business Rules as Unions

From Wlaschin's "contact must have email or address" example.

**Before** — two optional fields, both could be missing:

```typescript
interface Contact {
  readonly name: string
  readonly email?: string
  readonly postalAddress?: string
}
```

**After** — union enforces the rule at compile time:

```typescript
interface EmailOnly { readonly _tag: 'EmailOnly'; readonly email: EmailAddress }
interface PostalOnly { readonly _tag: 'PostalOnly'; readonly address: PostalAddress }
interface Both { readonly _tag: 'Both'; readonly email: EmailAddress; readonly address: PostalAddress }

type ContactInfo = EmailOnly | PostalOnly | Both

interface Contact {
  readonly name: PersonalName
  readonly contactInfo: ContactInfo
}
```

---

### Aggregate with Entity Identity

From Ghosh & Wlaschin: aggregates enforce consistency, referenced by id across boundaries.

```typescript
type AccountId = string & { readonly _brand: unique symbol }

interface Account {
  readonly id: AccountId
  readonly holder: string
  readonly balance: Balance
  readonly dateOfOpen: Date
  readonly dateOfClose: Option<Date>
}

interface Balance { readonly amount: number }

// Reference by id, not by embedding the whole entity
interface Portfolio {
  readonly accountIds: ReadonlyArray<AccountId>
  readonly asOf: Date
}
```

---

## Applicative Validation

From Ghosh Ch. 4 & 9: accumulate all validation errors instead of short-circuiting on the first.

**Before** — monadic flatMap stops at first error:

```typescript
import { pipe } from 'fp-ts/function'
import * as E from 'fp-ts/Either'

const validateAccount = (
  no: string,
  name: string,
  rate: number,
): E.Either<string, SavingsAccount> =>
  pipe(
    validateAccountNo(no),
    E.flatMap(() => validateName(name)),
    E.flatMap(() => validateRate(rate)),
    E.map((): SavingsAccount => ({ no, name, rate })),
  )
// If accountNo AND name are both invalid, only the accountNo error is reported.
```

**After** — applicative validation collects all errors:

```typescript
import { pipe } from 'fp-ts/function'
import * as E from 'fp-ts/Either'
import * as RA from 'fp-ts/ReadonlyArray'
import { sequenceS } from 'fp-ts/Apply'

interface ValidationError { readonly field: string; readonly message: string }
type ValidationErrors = ReadonlyArray<ValidationError>

const V = E.getApplicativeValidation(RA.getSemigroup<ValidationError>())
const apS = sequenceS(V)

const validateAccountNo = (no: string): E.Either<ValidationErrors, string> =>
  no.length >= 5
    ? E.right(no)
    : E.left([{ field: 'accountNo', message: 'Must be at least 5 chars' }])

const validateName = (name: string): E.Either<ValidationErrors, string> =>
  name.length > 0
    ? E.right(name)
    : E.left([{ field: 'name', message: 'Name cannot be empty' }])

const validateRate = (rate: number): E.Either<ValidationErrors, number> =>
  rate > 0
    ? E.right(rate)
    : E.left([{ field: 'rate', message: 'Rate must be positive' }])

const validateAccount = (
  no: string,
  name: string,
  rate: number,
): E.Either<ValidationErrors, SavingsAccount> =>
  pipe(
    apS({
      no: validateAccountNo(no),
      name: validateName(name),
      rate: validateRate(rate),
    }),
    E.map(({ no, name, rate }): SavingsAccount => ({ no, name, rate })),
  )
// All three errors reported together if all three fail.
```

---

## Workflows as Pipelines

From Wlaschin Ch. 7 & 9: a workflow is a function pipeline where each step's output feeds the next.

```typescript
import { pipe } from 'fp-ts/function'
import * as TE from 'fp-ts/TaskEither'
import * as E from 'fp-ts/Either'

// --- Domain types ---

interface PlaceOrderCommand { readonly order: UnvalidatedOrder }

interface OrderPlaced { readonly _tag: 'OrderPlaced'; readonly order: PricedOrder }
interface BillableOrderPlaced { readonly _tag: 'BillableOrderPlaced'; readonly orderId: OrderId; readonly amount: BillingAmount }
interface AcknowledgmentSent { readonly _tag: 'AcknowledgmentSent'; readonly orderId: OrderId; readonly email: EmailAddress }

type PlaceOrderEvent = OrderPlaced | BillableOrderPlaced | AcknowledgmentSent

interface OrderValidationFailed { readonly _tag: 'OrderValidationFailed'; readonly errors: ReadonlyArray<ValidationError> }
interface PricingError { readonly _tag: 'PricingError'; readonly message: string }

type PlaceOrderError = OrderValidationFailed | PricingError

// --- Pipeline steps (each is a typed function) ---

type ValidateOrder = (order: UnvalidatedOrder) => E.Either<PlaceOrderError, ValidatedOrder>
type PriceOrder = (order: ValidatedOrder) => TE.TaskEither<PlaceOrderError, PricedOrder>
type CreateEvents = (order: PricedOrder) => ReadonlyArray<PlaceOrderEvent>

// --- Composed workflow ---

const placeOrder = (
  validateOrder: ValidateOrder,
  priceOrder: PriceOrder,
  createEvents: CreateEvents,
) => (cmd: PlaceOrderCommand): TE.TaskEither<PlaceOrderError, ReadonlyArray<PlaceOrderEvent>> =>
  pipe(
    cmd.order,
    validateOrder,
    TE.fromEither,
    TE.flatMap(priceOrder),
    TE.map(createEvents),
  )
```

Dependencies are injected as function parameters. The core is pure composition.

---

## Dependency Injection via ReaderTaskEither

From Wlaschin Ch. 9 and Ghosh Ch. 3: inject infrastructure at the edges using Reader.

**Before** — direct import of infrastructure:

```typescript
import { db } from './infrastructure/database'

const getAccount = (id: AccountId): TE.TaskEither<Error, Account> =>
  TE.tryCatch(() => db.findAccount(id), E.toError)
```

**After** — dependencies as a Reader environment:

```typescript
import { pipe } from 'fp-ts/function'
import * as RTE from 'fp-ts/ReaderTaskEither'

interface AccountRepository {
  readonly findAccount: (id: AccountId) => TE.TaskEither<Error, Account>
  readonly saveAccount: (account: Account) => TE.TaskEither<Error, void>
}

interface Deps { readonly accountRepo: AccountRepository }

const getAccount = (id: AccountId): RTE.ReaderTaskEither<Deps, Error, Account> =>
  pipe(
    RTE.ask<Deps>(),
    RTE.flatMapTaskEither((deps) => deps.accountRepo.findAccount(id)),
  )

const transfer = (
  from: AccountId,
  to: AccountId,
  amount: Amount,
): RTE.ReaderTaskEither<Deps, Error, void> =>
  pipe(
    RTE.Do,
    RTE.bind('source', () => getAccount(from)),
    RTE.bind('target', () => getAccount(to)),
    RTE.bind('debited', ({ source }) => RTE.fromEither(debit(source, amount))),
    RTE.bind('credited', ({ target }) => RTE.fromEither(credit(target, amount))),
    RTE.flatMap(({ debited, credited }) =>
      pipe(
        RTE.ask<Deps>(),
        RTE.flatMapTaskEither((deps) =>
          pipe(
            deps.accountRepo.saveAccount(debited),
            TE.flatMap(() => deps.accountRepo.saveAccount(credited)),
          ),
        ),
      ),
    ),
  )
```

---

## Algebra / Interpreter Separation

From Ghosh Ch. 3 & 5: define the API as an algebra (interface), provide interpreters (implementations) separately.

```typescript
// --- Algebra (the contract) ---

interface AccountServiceAlgebra<F> {
  readonly open: (no: string, name: string, openDate: Date) => F
  readonly close: (account: Account, closeDate: Date) => F
  readonly debit: (account: Account, amount: Amount) => F
  readonly credit: (account: Account, amount: Amount) => F
  readonly balance: (account: Account) => F
}

// --- Interpreter for production (TaskEither) ---

const accountServiceInterpreter: AccountServiceAlgebra<TE.TaskEither<DomainError, Account>> = {
  open: (no, name, openDate) =>
    pipe(
      validateAccountNo(no),
      E.flatMap(() => validateOpenDate(openDate)),
      E.map((): Account => ({ id: no, holder: name, dateOfOpen: openDate, dateOfClose: O.none, balance: { amount: 0 } })),
      TE.fromEither,
    ),

  debit: (account, amount) =>
    account.balance.amount < amount
      ? TE.left({ _tag: 'InsufficientBalance' as const, message: 'Insufficient funds' })
      : TE.right({ ...account, balance: { amount: account.balance.amount - amount } }),

  credit: (account, amount) =>
    TE.right({ ...account, balance: { amount: account.balance.amount + amount } }),

  // ... close, balance
}

// --- Interpreter for testing (pure, in-memory) ---

const testAccountService: AccountServiceAlgebra<E.Either<DomainError, Account>> = {
  open: (no, name, openDate) =>
    E.right<DomainError, Account>({ id: no, holder: name, dateOfOpen: openDate, dateOfClose: O.none, balance: { amount: 0 } }),
  debit: (account, amount) =>
    account.balance.amount < amount
      ? E.left({ _tag: 'InsufficientBalance' as const, message: 'Insufficient funds' })
      : E.right({ ...account, balance: { amount: account.balance.amount - amount } }),
  // ...
}
```

---

## Lenses for Immutable Updates

See the **Encapsulate with Optics** before/after example in the refactoring skill's [reference.md](../refactoring/reference.md).

---

## Event Sourcing — Fold Events into State

From Ghosh Ch. 8: events are the source of truth; current state is a left fold.

```typescript
import * as RA from 'fp-ts/ReadonlyArray'

interface AccountOpened { readonly _tag: 'AccountOpened'; readonly id: AccountId; readonly name: string; readonly openDate: Date }
interface AmountDeposited { readonly _tag: 'AmountDeposited'; readonly id: AccountId; readonly amount: number }
interface AmountWithdrawn { readonly _tag: 'AmountWithdrawn'; readonly id: AccountId; readonly amount: number }
interface AccountClosed { readonly _tag: 'AccountClosed'; readonly id: AccountId; readonly closeDate: Date }

type AccountEvent = AccountOpened | AmountDeposited | AmountWithdrawn | AccountClosed

interface AccountState {
  readonly id: AccountId
  readonly name: string
  readonly balance: number
  readonly status: 'Open' | 'Closed'
}

const applyEvent = (state: AccountState, event: AccountEvent): AccountState => {
  switch (event._tag) {
    case 'AmountDeposited':
      return { ...state, balance: state.balance + event.amount }
    case 'AmountWithdrawn':
      return { ...state, balance: state.balance - event.amount }
    case 'AccountClosed':
      return { ...state, status: 'Closed' }
    case 'AccountOpened':
      return { id: event.id, name: event.name, balance: 0, status: 'Open' }
  }
}

const buildState = (events: ReadonlyArray<AccountEvent>): AccountState =>
  RA.reduce(
    { id: '' as AccountId, name: '', balance: 0, status: 'Open' as const },
    applyEvent,
  )(events)
```

---

## io-ts Codecs as Anti-Corruption Layer

From Wlaschin Ch. 11: translate between untrusted DTOs and trusted domain types at context boundaries.

```typescript
import * as t from 'io-ts'
import * as E from 'fp-ts/Either'
import { pipe } from 'fp-ts/function'
import * as OrderId from './OrderId'

// External DTO codec — what the outside world sends us
const OrderDTOCodec = t.type({
  orderId: t.string,
  customerName: t.string,
  items: t.array(
    t.type({
      productCode: t.string,
      quantity: t.number,
    }),
  ),
})

type OrderDTO = t.TypeOf<typeof OrderDTOCodec>

// Domain type (trusted, with branded types and validated invariants)
interface UnvalidatedOrder {
  readonly _tag: 'UnvalidatedOrder'
  readonly orderId: OrderId.OrderId
  readonly customerName: string
  readonly items: ReadonlyArray<UnvalidatedOrderLine>
}

// Anti-corruption layer: DTO → Domain
const toDomain = (dto: OrderDTO): E.Either<string, UnvalidatedOrder> =>
  pipe(
    OrderId.create(dto.orderId),
    E.map((orderId) => ({
      _tag: 'UnvalidatedOrder' as const,
      orderId,
      customerName: dto.customerName,
      items: dto.items.map((i) => ({
        productCode: i.productCode,
        quantity: i.quantity,
      })),
    })),
  )

// Input gate: raw JSON → validated DTO → domain type
const parseOrder = (raw: unknown): E.Either<string, UnvalidatedOrder> =>
  pipe(
    OrderDTOCodec.decode(raw),
    E.mapLeft((errors) => `Invalid order DTO: ${JSON.stringify(errors)}`),
    E.flatMap(toDomain),
  )
```

---

## Property-Based Testing

From Ghosh Ch. 9: encode business rules as algebraic properties verified with generated data.

```typescript
import * as fc from 'fast-check'
import { pipe } from 'fp-ts/function'
import * as E from 'fp-ts/Either'

// Generator using smart constructor
const unitQuantityArb: fc.Arbitrary<UnitQuantity> = fc
  .integer({ min: 1, max: 1000 })
  .map((n) => n as UnitQuantity)

const amountArb: fc.Arbitrary<Amount> = fc
  .integer({ min: 1, max: 100000 })
  .map((n) => (n / 100) as Amount)

// Property: credit then debit of equal amount preserves balance
test('credit and debit of equal amount is identity on balance', () => {
  fc.assert(
    fc.property(amountArb, (amount) => {
      const account: Account = {
        id: 'test-001' as AccountId,
        holder: 'Test',
        balance: { amount: 1000 },
        dateOfOpen: new Date(),
        dateOfClose: O.none,
      }

      const result = pipe(
        credit(account, amount),
        E.flatMap((credited) => debit(credited, amount)),
      )

      expect(pipe(result, E.map((a) => a.balance.amount))).toEqual(
        E.right(account.balance.amount),
      )
    }),
  )
})

// Property: closing an already-closed account fails
test('close on already closed account fails', () => {
  fc.assert(
    fc.property(fc.date(), (closeDate) => {
      const closedAccount: Account = {
        id: 'test-002' as AccountId,
        holder: 'Test',
        balance: { amount: 0 },
        dateOfOpen: new Date('2020-01-01'),
        dateOfClose: O.some(new Date('2023-01-01')),
      }

      const result = closeAccount(closedAccount, closeDate)
      expect(E.isLeft(result)).toBe(true)
    }),
  )
})
```

---

## Abstract Early, Evaluate Late — Do Notation

From Ghosh's core principle: compose computations (not values) and commit to a result only at the boundary.

**Before** — eagerly evaluated, hard to compose:

```typescript
const getBalance = async (accountNo: string): Promise<number> => {
  const account = await db.findAccount(accountNo)
  if (!account) throw new Error('Account not found')
  return account.balance.amount
}
```

**After** — composed computations, evaluated at the edge:

```typescript
import { pipe } from 'fp-ts/function'
import * as TE from 'fp-ts/TaskEither'

const getBalance = (accountNo: AccountId): TE.TaskEither<DomainError, number> =>
  pipe(
    findAccount(accountNo),
    TE.map((account) => account.balance.amount),
  )

const getNetAssetValue = (accountNo: AccountId): TE.TaskEither<DomainError, number> =>
  pipe(
    TE.Do,
    TE.bind('balance', () => getBalance(accountNo)),
    TE.bind('interest', ({ balance }) => calculateInterest(accountNo, balance)),
    TE.map(({ balance, interest }) => balance + interest),
  )

// Evaluation happens only at the application boundary:
// pipe(getNetAssetValue(accountId), TE.fold(handleError, handleSuccess))()
```
