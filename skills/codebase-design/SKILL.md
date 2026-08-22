---
name: codebase-design
description: Design and improve deep modules with small interfaces, clean seams, strong locality, and tests through the interface. Use when designing or restructuring a module, placing a seam, reducing shallow indirection, improving testability, exploring alternative interfaces, or explicitly reviewing a codebase for architecture improvements.
license: MIT; adapted from Matt Pocock's codebase-design and improve-codebase-architecture skills
---

# Codebase design

Design deep modules: substantial behavior behind a small interface, placed at a clean seam and testable through that interface. The goals are leverage for callers, locality for maintainers, and stable tests.

## Progressive loading

Keep architecture-review instructions out of context unless they are needed.

- For ordinary module design, interface design, seam placement, or local restructuring, use this file only.
- Read [`references/DEEPENING.md`](references/DEEPENING.md) when restructuring a cluster whose dependencies affect seam placement or testing.
- Read [`references/DESIGN-IT-TWICE.md`](references/DESIGN-IT-TWICE.md) only when the user wants alternative interface designs or when the first interface proposal carries important trade-offs.
- Read [`references/IMPROVE-CODEBASE-ARCHITECTURE.md`](references/IMPROVE-CODEBASE-ARCHITECTURE.md) only when the user explicitly asks to improve, audit, assess, or find architectural opportunities across a codebase or subsystem. Do not read it merely because a local refactor could improve architecture.

## Vocabulary

Use these words consistently when discussing architecture.

**Module**: anything with an interface and an implementation. It may be a function, class, package, or a slice spanning several technical tiers. Prefer module over component, unit, or service when discussing this concept.

**Interface**: everything a caller must know to use a module correctly. This includes types, invariants, ordering constraints, errors, configuration, and relevant performance characteristics. It is broader than a type signature.

**Implementation**: the code and behavior hidden inside a module. Use adapter instead when discussing the concrete participant at a seam.

**Depth**: the leverage provided by an interface. A deep module gives callers substantial behavior through a small interface. A shallow module exposes nearly as much complexity as its implementation contains.

**Seam**: a place where behavior can change without editing the caller. It is the location where a module's interface lives. Seam placement and interface design are separate decisions.

**Adapter**: a concrete participant that satisfies an interface at a seam. Adapter describes its role, not how much code it contains.

**Leverage**: the capability callers receive for the interface they must learn. One implementation pays back across many call sites and tests.

**Locality**: the concentration of change, knowledge, bugs, and verification inside one module instead of distributing them among callers.

## Deep and shallow modules

A deep module has a small interface and a substantial implementation:

```text
┌─────────────────────┐
│   Small interface   │
├─────────────────────┤
│                     │
│ Deep implementation │
│                     │
└─────────────────────┘
```

A shallow module has an interface nearly as complicated as its implementation:

```text
┌─────────────────────────────────┐
│         Large interface         │
├─────────────────────────────────┤
│       Thin implementation       │
└─────────────────────────────────┘
```

When shaping an interface, ask:

- Can it have fewer entry points?
- Can its parameters become simpler?
- Which ordering rules or invariants can the implementation absorb?
- Can callers stop coordinating steps that always belong together?
- Does the interface expose implementation choices that callers should not know?

## Core principles

### Depth belongs to the interface

Do not measure depth by counting implementation lines. A module is deep when its callers receive high leverage from a small interface. Its implementation may still contain private helpers and internal seams.

### Apply the deletion test

Imagine deleting the module.

- If its complexity disappears, the module was likely pass-through indirection.
- If its complexity spreads into several callers, the module was providing locality and leverage.

Deletion is a thought experiment, not an instruction to remove code without evidence.

### Treat the interface as the test surface

Callers and tests should cross the same seam. If tests must reach past the interface, either the interface hides the wrong behavior or the module has the wrong shape.

Prefer tests that assert observable behavior. They should survive internal restructuring.

### Require real variation before adding a seam

One adapter usually means a hypothetical seam. Two justified adapters make the seam real, often production and test adapters. Do not add indirection for imagined future variation.

### Hide coordination

If every caller performs the same sequence, validation, retry, mapping, or error translation, move that coordination behind one interface. Repeated caller knowledge is a strong deepening signal.

## Designing for testability

### Accept dependencies

Do not construct replaceable dependencies deep inside behavior that needs testing.

```typescript
function processOrder(order: Order, payments: Payments): Promise<Result> {
  // ...
}
```

Avoid:

```typescript
function processOrder(order: Order): Promise<Result> {
  const payments = new StripePayments();
  // ...
}
```

### Return observable results

Prefer results that callers and tests can inspect. Keep unavoidable side effects behind an explicit seam.

```typescript
function calculateDiscount(cart: Cart): Discount {
  // ...
}
```

### Keep the external interface small

Internal composition is compatible with a small external interface. Do not expose private helpers solely so tests can call them.

## Design workflow

1. Identify callers and list everything each caller must currently know.
2. Name the behavior that should be local to one module.
3. Choose the seam independently from the implementation structure.
4. Sketch the smallest interface that supports real caller needs.
5. Record its full contract: inputs, outputs, invariants, ordering, errors, configuration, and meaningful performance constraints.
6. Decide what coordination and dependency handling move behind the seam.
7. Test through the interface with observable outcomes.
8. Apply the deletion test and check that the new module increases locality rather than adding pass-through indirection.
9. Describe migration and deletion work. Deepening should normally remove old entry points and obsolete tests, not layer a new interface over them forever.

## Review checklist

Before recommending a design, verify:

- The interface is smaller than the behavior it unlocks.
- Callers no longer coordinate hidden implementation steps.
- The seam corresponds to actual variation or a useful test substitution.
- Tests use the same interface as callers.
- Internal seams remain internal.
- Errors and ordering requirements are explicit.
- The proposal removes shallow modules or repeated knowledge.
- The migration has a clear path to deleting superseded code.

## Attribution

This skill adapts ideas and material from Matt Pocock's `codebase-design` and `improve-codebase-architecture` skills. See [`NOTICE.md`](NOTICE.md).
