## Why

Sales reps currently have no way in the mobile app to capture or review photo
evidence gathered during a customer survey (property condition, pest
sighting, site access, etc.), even though the backend API for it already
ships (`POST/GET/DELETE /api/v1/sales/customers/:id/photos`, see
`docs/api/customer-photos.md`). Without this UI, evidence collected in the
field has no home and reps fall back to ad hoc channels (WhatsApp, personal
galleries) that are not tied to the customer record.

## What Changes

- Add a **Foto** tab to the customer detail pane (`CustomerDetailPane`),
  alongside the existing Informasi Utama / Lokasi & Titik Servis / Kontak
  Person & PIC / Riwayat Proposal tabs.
- Show a grid of the customer's survey photos (thumbnail, uploader-visible
  metadata), oldest-first, matching the API's ordering.
- Let a rep add a photo via camera capture or gallery pick (action sheet:
  "Ambil Foto" / "Pilih dari Galeri"), upload it as `multipart/form-data`,
  and see it appear in the grid on success.
- Automatically compress the photo client-side (resize to a max 1280px
  longest side, ~70% JPEG quality) before uploading, to reduce upload size
  and time on field connections and to let some otherwise-oversized photos
  fit under the server's size limit.
- Let a rep delete a photo from the grid, with a confirmation step.
- Let a rep tap a thumbnail to open a simple full-screen viewer (pinch-zoom,
  close button, delete action) — view only, no client-side compression or
  editing.
- Surface the API's existing validation errors (unsupported file type, file
  too large, 5-photo limit, not found) as inline UI feedback using their
  `http_status` code, not by parsing `message` text (per the API's own
  guidance for mobile implementers).
- Add `image_picker` as a new dependency (no existing package in this repo
  handles camera/gallery selection or multipart upload).
- Add `flutter_image_compress` as a new dependency for the client-side
  compression step.

No existing capability's requirements change; this is a new capability.

## Capabilities

### New Capabilities
- `customer-photos`: Sales reps can upload, view, and delete survey photos
  attached to a customer record via the mobile app, backed by the existing
  `sales.customer.photo.*` permissioned API.

### Modified Capabilities
(none)

## Impact

- **New files**: `CustomerPhoto` entity, `CustomerPhotoDto`,
  `CustomerPhotoRepository` (+ impl), `CustomerPhotoController`, a
  `CustomerPhotosTab` view widget, and a full-screen photo viewer widget.
- **Modified files**: `CustomerDetailPane` (add 5th tab + wiring),
  `app/di.dart` (register the new repository + controller), `pubspec.yaml`
  (add `image_picker`, `flutter_image_compress`), platform permission
  manifests (`android/app/src/main/AndroidManifest.xml`,
  `ios/Runner/Info.plist`) for camera/photo-library access.
- **API dependency**: `POST/GET/DELETE /api/v1/sales/customers/:id/photos`
  (`docs/api/customer-photos.md`) — already implemented server-side, no
  backend changes needed.
- **Permissions consumed**: `sales.customer.photo.create`,
  `sales.customer.photo.view`, `sales.customer.photo.delete` — this change
  assumes the logged-in sales role already has these; it does not add
  permission-gating UI beyond surfacing 403 errors if the server rejects a
  call.
