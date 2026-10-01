## Why

The backend customer survey photos API contract (`/api/v1/sales/customers/:id/photos`) has been updated to require a non-empty `title` for each photo upload and support an optional `notes` field. Currently, the mobile app uploads photos without sending `title` or `notes`, causing requests to fail with HTTP 400 (`"Judul foto wajib diisi"`), and does not display these metadata fields in the photo gallery or viewer. Updating the app aligns it with the API contract and allows sales reps to clearly label and describe survey evidence.

## What Changes

- **Photo Upload Metadata**: When a user captures or selects a photo, prompt for a mandatory `title` (trimmed, non-empty) and optional `notes` before uploading.
- **Photo Upload Payload**: Send `title` (trimmed) and `notes` (if non-empty) in the multipart form data alongside `photo`.
- **Entity and DTO Updates**: Add `title` and `notes` properties to `CustomerPhoto` entity and `CustomerPhotoDto` to deserialize and represent survey photo metadata.
- **UI Enhancements**:
  - Show the photo title and notes in the customer photo thumbnails and in the full-screen photo viewer.
  - Display photo count and respect the 5-photo limit in the UI (prevent or warn before uploading when limit is reached).

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `customer-photos`: Update requirement for adding a survey photo to require title input and allow optional notes, and update viewing requirements to display photo title and notes.

## Impact

- **Affected Domain/Layers**:
  - Entity: `lib/modules/sales/entities/customer_photo.dart`
  - DTO: `lib/modules/sales/repositories/dtos/customer_photo_dto.dart`
  - Repository: `lib/modules/sales/repositories/customer_photo_repository.dart`
  - Controller: `lib/modules/sales/controllers/customer_photo_controller.dart`
  - Views: `lib/modules/sales/views/widgets/customer_photos_tab.dart`, `lib/modules/sales/views/widgets/customer_photo_viewer.dart`
- **APIs**:
  - `POST /api/v1/sales/customers/:id/photos` (adds multipart fields `title` and `notes`)
  - `GET /api/v1/sales/customers/:id/photos` (parses `title` and `notes` in response items)
- **Breaking Changes**: None for external consumers. Internal method signatures for `uploadPhoto` and `addPhoto` will take `title` and `notes`.
