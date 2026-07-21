# React Native / Expo uploads

On React Native, `FormData` only sends parts that carry a `uri` — it never reads a Blob's bytes. But file validators (`z.file()`, this package's `file()`, any `instanceof File` check) expect a real `File`. `ReactNativeFile` is both: a genuine `File` subclass that *also* carries the `uri` RN needs, so it passes validation **and** uploads correctly. Import it from `.../client`.

## From a picker

Build it synchronously from the picker result and use it as a form value — no `fetch`, no reading the file into memory:

```ts
import { ReactNativeFile } from '@falcondev-oss/trpc-typed-form-data/client'

const { assets } = await ImagePicker.launchImageLibraryAsync()
const asset = assets[0]

const file = new ReactNativeFile({
  uri: asset.uri,                       // local file URI from the picker; used for the upload
  name: asset.fileName ?? 'upload.jpg', // sent as the multipart filename
  type: asset.mimeType,                 // MIME type, e.g. 'image/jpeg'
  size: asset.fileSize,                 // bytes — see below
})

await trpc.upload.mutate(createTypedFormData({ userId: '123', file }))
```

Only `uri` and `name` are required; `type` and `size` are optional.

## From a remote URL

`ReactNativeFile.fromUrl(url, fileName?)` sends a `HEAD` request to read `content-type` and `content-length` — the body is **not** downloaded; the upload streams from `url`. `fileName` defaults to the last path segment.

```ts
const file = await ReactNativeFile.fromUrl('https://example.com/photo.jpg')
```

## Why `size` matters

`File.size` on the empty blob backing a `ReactNativeFile` reports `0`. Pass the real `size` (e.g. `asset.fileSize`) or size checks — `file({ maxSize })`, `z.file().min()/max()` — will see `0` and mis-validate. `ReactNativeFile` shadows `name`/`size` with writable own properties for two reasons: to report the real size, and because Expo's fetch/FormData polyfill reassigns `name`, which throws on a read-only getter in strict mode ([expo#35512](https://github.com/expo/expo/issues/35512)).

## Type across the boundary

Annotate the shared schema's file field with this package's `file()` (not `z.file()`) so the inferred type stays `FileValue` on the RN client instead of degrading to `any`. See the main SKILL for the `file()` vs `z.file()` rationale.
