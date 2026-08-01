# Coding Standards

## Companion standards

Rules scoped to one package or feature live in a sibling `*_STANDARDS.md` — e.g. `PRISMA_STANDARDS.md`. Each is in force only where its subject is present: a `schema.prisma` in the tree puts the Prisma rules in force. List the siblings, read every one whose subject the repo uses, and ignore the rest.

## Optionality — slots and offers

- A **slot** is a decision the caller must make. Force it — make the omission a compile error.
- An **offer** is functionality the caller may ignore.

The test: **could omitting this produce a wrong value the caller should have decided?** Yes → slot. No → offer.

Slots are value-optional: `{ foo: string | undefined }`. The caller must write `foo:` and pass a value.

Offers are key-optional: `{ foo?: string }`. Reach for `?` when:

- **Opt-in capability** — an extra button, a callback, a decoration. Example: `secondaryAction?: { onSelect, icon, label }` — most usages have no secondary action, and that is complete behaviour.
- **Matching a third-party type**, or a **discriminated union** where the key's presence carries meaning.

## `null` vs `undefined`

Keep the meanings distinct: `undefined` is _absence_ ("never set"), `null` is _presence of emptiness_ ("a value was chosen, and that value is nothing"). A caller deliberately clearing or emptying a field writes `null`.

## Exports

Export only what another file imports.

## Tests

Two bars. A test earns its place only by clearing both.

**1. Worth testing.** Could a plausible mistake here **compile but produce a wrong answer**? That's branching logic, edge and boundary cases, data transformations, parsing, date/timezone math, and invariants that must hold across inputs. Where the types already guarantee the behaviour — a trivial getter, a pure re-export, a passthrough — the test protects nothing and adds maintenance weight and false confidence.

**2. Goes red.** Watch it fail for the intended reason before the implementation exists. When backfilling onto existing code, break the code, confirm the test goes red, then restore the code.

The anti-pattern is the **mirror test**: one that restates the implementation line-for-line, asserting the function calls exactly what you wrote it to call with the same literals. Change the code and the test changes with it, so it can never catch a regression — only re-assert the current source. It is the test-shaped twin of a comment that restates the code.

## Comments

**Every comment load-bearing.** One bar, and it is one-sided: a comment earns its place only if you can name, in a sentence, what a competent reader would get wrong without it — _why_ this approach over the obvious one, a non-obvious invariant or consequence, a gotcha or external constraint, a reference. No such sentence, no comment: the code ships alone.

The audience is **the reader who never saw the diff** — a stranger opening the file in a year, with no ticket, no PRD, no chat history — read in the register of JSDoc on a library another programmer consumes. The ticket, ADR, or spec the code satisfies, what was tried first, and any justification aimed at the reviewer belong in the PR description; a comment addressed to whoever requested the code fails the bar even when it is accurate.

The anti-pattern is the **translation**: a comment restating the line beneath it (`// increment the counter` over `counter++`). It carries no load, and it is a second thing to keep in sync.

Model case — given `if (parsed.dateIso !== todayIso) return []`, the code shows only that stale dates yield an empty array. The comment carries the intent that check serves: _stale data is never read, so effectively only today's data is live._
