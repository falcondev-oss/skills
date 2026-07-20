# Optional features

## Arrays

Beyond `.at(i)` / iteration / `.delete(key)` (in SKILL.md):

- Replacing the whole array (`arrayField.handleChange([...])` or `form.data.items = [...]`) **clears the field cache** for that array, so every item's `field.key` changes. Rely on `field.key` for list `:key`s so rows re-mount correctly.
- Mutating methods on the reactive data work and stay in sync with field keys: `form.data.items.push(x)`, `.unshift`, `.splice`, `.sort`, `.reverse`, `.fill`.
- `arrayField.delete(key)` splices by an item key; passing a nested field's key (e.g. the key of `items[2].name`) throws `"Key does not reference an array item"`.

```ts
form.fields.items.delete(form.fields.items.at(2).$use().key) // removes items[2]
```

## Value translation — `$use({ translate })`

Bidirectionally map between the **stored** value and the value the field/UI works with. `field.value` becomes the translated type; `handleChange` takes the translated type and stores the raw one. Errors and validation still run on the stored value.

```ts
// stored as ISO string, edited as a Date
const dateField = form.fields.birthday.$use({
  translate: {
    get: (v) => (v ? new Date(v) : null),        // stored → display
    set: (v) => v?.toISOString().split('T')[0] ?? null, // display → stored
  },
})
dateField.value        // Date | null
dateField.model        // Vue: WritableComputedRef<Date>; React: {value: Date, onUpdate}
dateField.handleChange(new Date()) // writes the ISO string into form.data
```

The return type is inferred from `get` (via `NoInfer`, so the field type follows the translator, not the schema).

## Discriminated unions — `$use({ discriminator })`

For a discriminated-union field, `$use({ discriminator: 'type' })` returns a reactive `{ [discriminator], $field }` where the discriminator value narrows `$field`'s child accessors:

```ts
const schema = z.object({
  union: z.discriminatedUnion('type', [
    z.object({ type: z.literal('A'), value: z.string() }),
    z.object({ type: z.literal('B'), value: z.number() }),
  ]),
})

const u = form.fields.union.$use({ discriminator: 'type' })
u.type                       // 'A' | 'B' | null  (reactive current value)

if (u.type === 'A') {
  u.$field.$use().value      // whole branch object, typed { type:'A'|null, value:string|null } | null
  u.$field.value.$use()      // reach a child: FormField<string | null> (A branch)
} else if (u.type === 'B') {
  u.$field.value.$use()      // FormField<number | null> (B branch)
}
```

- The discriminator **field itself** (to build a `<select>` that switches branch) is a normal accessor: `form.fields.union.type.$use()` → `FormField<'A' | 'B' | null>`.
- `'type' in u.$field` works for presence checks.
- Multiple discriminator keys and non-string literals (`boolean`, `number`) are supported; each discriminator key gets its own accessor with the union of its literal values.
- The library auto-detects a discriminated union (a union of objects sharing a key whose value distinguishes the members) — no discriminator option is needed just to read; it's needed to get **narrowed** `$field` children.

## Field metadata — `field.schema`

`field.schema` (`SchemaMeta`) is extracted from the schema's JSON Schema — use it to render labels, `required` marks, and native input constraints:

| Field | From (zod example) |
|---|---|
| `required` | not `.optional()`/`.nullable()` and present in parent `required` |
| `title`, `description`, `examples`, `default` | `.meta({ title, description, examples })`, `.default(x)` |
| `minLength`, `maxLength` | `.min(n)` / `.max(n)` on strings |
| `minimum`, `maximum` | `.min(n)` / `.max(n)` on numbers |
| `exclusiveMinimum`, `exclusiveMaximum` | `.gt(n)` / `.lt(n)` |

```ts
const f = form.fields.name.$use()
<input required={f.schema.required} maxLength={f.schema.maxLength}
       placeholder={f.schema.title} />
```

For unions, the constraints track the branch matching the current value (including fields nested inside a discriminated union). If the schema isn't JSON-Schema-representable `field.schema` is `{}` — whole-schema generation failures warn at form creation; an unsupported construct on a single field degrades silently (a dev warning fires only under `__FORM_DEBUG__`).

## Hooks

Pass via the `hooks` option or register later with `form.hooks.hook(name, fn)` / `hookOnce` / `addHooks`. All may be async and are awaited in order.

| Hook | Signature | Fires |
|---|---|---|
| `beforeSubmit` | `({ data }) => …` | before validation on submit |
| `afterSubmit` | `({ success }) => …` | after `submit` resolves (or validation fails) |
| `beforeValidate` | `() => …` | before schema validation |
| `afterValidate` | `(result) => …` | after validation, with the Standard Schema result |
| `beforeFieldChange` | `(field, newValue) => …` | before a field value is written |
| `afterFieldChange` | `(field, updatedValue) => …` | after a field value is written |

Submit order is `beforeSubmit → submit → afterSubmit`.

```ts
useForm({
  schema, sourceValues,
  hooks: {
    async beforeSubmit({ data }) { /* … */ },
    afterSubmit({ success }) { if (success) toast('Saved') },
  },
  async submit({ values }) { await api.save(values) },
})
```

## Extending fields (advanced)

The framework adapters add `field.model` via a private `extend` symbol plus module augmentation of `FormFieldExtend`. App code rarely needs this, but it's how you'd attach custom per-field members:

```ts
import { extend } from '@falcondev-oss/form-core'
declare module '@falcondev-oss/form-core' {
  interface FormFieldExtend<T> { myThing: SomeType }
}
useFormCore({ schema, sourceValues, submit,
  [extend]: { $use: (field) => ({ myThing: /* derive from field */ }) },
})
```

Both `setup` and `$use` run once, when the field is first materialized (their results are merged into `field.api`). This is the mechanism the React/Vue `useForm` wrappers use to add `model` — prefer them over hand-rolling `extend`.
