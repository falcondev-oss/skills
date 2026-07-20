# Framework specifics

The handle and field API are identical everywhere. Only **binding** and **re-render** differ.

## React (`@falcondev-oss/form-react`)

React has no built-in reactivity, so the adapter bridges `@vue/reactivity` to React renders with an internal tick counter. Two consequences drive everything:

1. **`useForm` is memoized** — the form instance is created once and survives re-renders. It internally watches `errors`/`isLoading`/`isChanged`/`isDirty`, **and every `$use`d field's `value`/`errors`**, and forces a re-render of **the component that called `useForm`** when any change.
2. **`$use()` does not subscribe the caller.** The field's watcher re-renders the `useForm`-owning component, not whoever calls `$use()`. A **child** component that renders a field it received as a prop must call `useField(field)` (or be a `FormFieldMemo`) to re-render on that field's changes — otherwise it only updates via the parent cascade, which breaks under memoization.

### Binding an input — `field.model`

React's `model` is `{ value, onUpdate }` for controlled inputs. A leaf input component takes the field as a prop and subscribes with `useField`:

```tsx
function NameInput({ field }: FormFieldProps<string>) {
  useField(field)                                // subscribe THIS component
  return (
    <input
      value={field.model.value ?? ''}            // value is NullableDeep → coalesce
      onChange={(e) => field.model.onUpdate(e.target.value)}
      onBlur={field.handleBlur}
    />
  )
}

// parent (the useForm owner) materializes and passes the field down:
<NameInput field={form.fields.name.$use()} />
```

If you instead read the field directly in the same component that called `useForm` (`const field = form.fields.name.$use()` in that body), no `useField` is needed — that component is already the subscriber.

`field.model.onUpdate` is just `field.handleChange`; use whichever reads better.

### `useField(field)`

Subscribe a component to a field you received as a prop (rather than `$use`-ing it locally). Returns the same field; the point is the subscription:

```tsx
function FieldError({ field }: FormFieldProps<string>) {
  useField(field)                                // re-render when this field changes
  return field.errors ? <span>{field.errors[0]}</span> : null
}
```

### `FormFieldMemo` — skip re-renders

Wrap a leaf field component so it re-renders **only** when its own field ticks (not when unrelated form state changes). Pass the field as a `field` prop (`FormFieldProps<T>`):

```tsx
const Row = FormFieldMemo<string, { label: string }>(({ field, label }) => {
  useField(field)
  return <label>{label}<input value={field.model.value ?? ''}
    onChange={(e) => field.model.onUpdate(e.target.value)} /></label>
})
```

### Types

`FormFieldProps<T>` is `{ field: FormField<NullableDeep<T>> }` — the canonical prop type for a component that takes a field. `FieldModel<T>` / `FieldModelProps<T>` describe the `model` shape if you pass `model` around directly.

## Vue (`@falcondev-oss/form-vue`)

`useForm` returns a `reactive` object — use it directly in templates, no subscription step. Field binding is a real `v-model`:

```vue
<script setup>
const form = useForm({ schema, sourceValues, async submit() {} })
const name = form.fields.name.$use()
</script>

<template>
  <input v-model="name.model" @blur="name.handleBlur" />
  <p v-if="name.errors">{{ name.errors[0] }}</p>
  <button :disabled="form.isDisabled" @click="form.submit">Save</button>
</template>
```

`field.model` here is a `WritableComputedRef<T>` — reads `field.value`, writes via `field.handleChange`. `form.data`, `form.isDirty`, etc. are reactive; watch them normally.

`sourceValues` may be a plain object, a `ref`, or a getter — all tracked.

### `useFormHandles(forms)`

Aggregate several forms into one `FormHandle` — combined `isChanged`/`isDirty`/`isLoading`/`isDisabled`/`errors`, a `submit()` that awaits all, a `reset()` for all, and shared `hooks`. Use for multi-form pages / wizards:

```ts
const combined = useFormHandles(() => [formA, formB])
await combined.submit()   // submits both
```

## Core standalone (`@falcondev-oss/form-core`)

`useFormCore` is the engine — no framework re-render integration and **no `field.model`**. Use it only outside React/Vue (or in tests). Reactivity is raw `@vue/reactivity`: read `form.data`/`field.value` and drive UI with `watch`/`effect` yourself.

```ts
import { useFormCore } from '@falcondev-oss/form-core'
import { watch } from '@vue/reactivity'

const form = useFormCore({ schema, sourceValues, async submit() {} })
watch(() => form.data.name, (v) => render(v))
form.fields.name.$use().handleChange('Jane')
```

The `/reactive` subexport (`@falcondev-oss/form-core/reactive`) provides `refEffect`, `toReactive`, `reactiveComputed` — internal helpers, rarely needed in app code.
