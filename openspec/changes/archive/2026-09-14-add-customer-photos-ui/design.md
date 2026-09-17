## Context

See `proposal.md` - Why/What Changes. The customer module already follows a
strict layered architecture (`View → Controller → Repository → Entity`,
Signals for state, `get_it` for DI, Dio for HTTP) documented in the repo's
`CLAUDE.md`. `CustomerDetailPane` currently renders 4 static tabs
(`CustomerInfoTab`, `CustomerLocationsTab`, `CustomerContactsTab`,
`CustomerProposalsTab`) driven by an `activeTab` int on `CustomerController`.
No existing repository performs a multipart upload, and no package in
`pubspec.yaml` handles camera/gallery selection — this is the first feature
to need either.

## Goals / Non-Goals

**Goals:**
- Fit the new feature into the existing layered architecture without
  introducing a new pattern (no DataSource layer, no new state-management
  approach).
- Keep photo state scoped to the currently selected customer, sourced fresh
  from the API rather than cached across customers, matching how
  `CustomerController.selectCustomer` already treats the detail record.
- Keep the multipart upload and image-selection concerns inside the
  repository/controller pair for this capability, not leaked into the view.
- Compress a photo client-side before upload, to reduce upload size/time on
  field connections and let some otherwise-oversized photos fit under the
  server's limit, without adding a general image-editing capability.

**Non-Goals:**
- Cropping, rotating, or otherwise manually editing a photo before upload —
  compression is automatic and non-interactive; the rep does not choose
  crop bounds or rotation.
- Offline queueing of uploads (API is a required round trip; no offline
  support elsewhere in the app to match).
- Multi-select / bulk upload — one photo per add action, matching the
  camera-or-gallery action sheet.
- Any change to the existing 4 tabs or `CustomerDetailPane` header actions.

## Decisions

**New `CustomerPhotoController`, not folded into `CustomerController`.**
`CustomerController` already owns list/detail/filter state for the whole
customer module; photo state (list, upload progress, per-photo delete state)
is a self-contained slice used only by one tab. A separate controller keeps
`CustomerController` from growing an unrelated responsibility and matches
the existing precedent of tab-scoped data living outside the parent
controller where the tab's data isn't part of the `Customer` entity itself
(contacts/locations/proposals *are* embedded in `Customer` and rendered
statelessly; photos are not embedded in `Customer` per the API, so they need
their own fetch/state lifecycle). The tab widget (`CustomerPhotosTab`)
resolves its own controller from `get_it` the same way a page does, since it
has its own load/dispose lifecycle independent of the parent pane's build
cycle.
Alternative considered: extend `Customer` entity with a `photos` field
fetched as part of `getCustomerById`. Rejected — the API defines photos as a
separate resource with its own endpoints and pagination-free list, and
`CustomerDetailPane`'s other tabs already read straight from `Customer`
fields that come back in one shot; forcing photos into that same call would
require always fetching photos even when the rep never opens the Foto tab.

**`image_picker` for camera/gallery selection.** It is the standard
Flutter-maintained plugin for this, already handles Android/iOS runtime
permission prompts, and returns an `XFile` that Dio's `MultipartFile.fromFile`
consumes directly. Alternative considered: `file_picker` (broader, any file
type) — rejected as it doesn't distinguish camera vs. gallery capture, which
the proposal's UX calls for.

**Repository takes `XFile`/file path, not raw bytes, as the upload
parameter.** Keeps the multipart construction (`FormData` +
`MultipartFile.fromFile`) inside the repository per the architecture rule
that only repositories touch Dio directly, while the controller and view
only ever handle a `String` path returned by `image_picker` — no image
bytes cross into the controller layer.

**Compression happens inside `CustomerPhotoRepositoryImpl.uploadPhoto`,
before building `FormData`, not in the controller or view.** CLAUDE.md
restricts `try/catch` to the repository layer, and a native compression
call (`flutter_image_compress`) can throw; keeping compression in the
repository keeps that the only layer touching it, and keeps `addPhoto` in
the controller and the picked-file handling in the view unchanged — they
still just pass a file path through. `flutter_image_compress` is chosen
over the `image` package (already present transitively via `image_picker`)
because it compresses natively off the Dart UI isolate, which matters for
large camera captures, whereas the `image` package decodes/resizes/encodes
in pure Dart and would need explicit `compute()`/isolate offloading to
avoid jank. Target: resize to a max 1280px longest side, ~70% JPEG quality,
always re-encoded to JPEG regardless of the original format — camera/gallery
captures are typically already JPEG, and standardizing the output avoids
extra branching while JPEG is always accepted by the API.

**Entity models the API response shape directly (`CustomerPhoto`: id, url,
originalName, mimeType, fileSize, createdAt, createdBy)** with no derived
fields beyond what the view needs (e.g. a `sizeLabel` getter for display),
following the existing entity style (see `CustomerContact`, `CustomerLocation`
getters).

**Errors surfaced via `Failure.message` sourced from `http_status`, not
`message` text**, per the API doc's explicit guidance to mobile
implementers. The repository maps known status codes (400 variants, 401,
403, 404) to specific `ServerFailure` messages in Bahasa Indonesia
(consistent with the rest of the app's UI copy), matching the pattern already
used in `CustomerRepositoryImpl._handleDioError`.

**Full-screen viewer is a new shared-ish widget local to the sales module**
(`views/widgets/customer_photo_viewer.dart`), opened via
`Navigator.push`/`showDialog` from the tab, not a route — it's a transient
overlay over existing state, not a distinct navigable page, matching how the
app has no existing full-screen image viewer to reuse.

## Risks / Trade-offs

- [Risk] `image_picker` requires new platform permission entries
  (`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` on iOS;
  `CAMERA`/media permissions on Android) → Mitigation: add them as part of
  this change's tasks; without them the app crashes on first camera/gallery
  access on iOS and is silently denied on newer Android, so this is not
  optional.
- [Risk] Large photo uploads on slow connections block the add-photo flow
  with no progress indicator by default → Mitigation: surface Dio's
  `onSendProgress` as a simple upload-in-progress indicator in the tab (not
  a percentage bar) so the rep isn't left wondering if the tap registered.
- [Risk] Deleting a photo optimistically before the server confirms could
  show incorrect state on failure → Mitigation: per spec, delete is
  confirmed-then-pending until the server responds; the photo is only
  removed from local state after a successful `Ok` result, not before.
- [Risk] 1280px/~70% JPEG compression could be too aggressive for a survey
  photo where fine detail matters (e.g. a small pest sighting) → Mitigation:
  this target is a starting point, not a hard constraint on the repository's
  public method; adjust the constants if reps report legibility issues,
  without changing the method signature or any other layer.

## Migration Plan

No data migration — this is a new, additive UI feature against an existing
API with no backend changes. Rollout is a normal app release; no rollback
concerns beyond reverting the release if the new tab misbehaves, since no
other feature depends on it.
