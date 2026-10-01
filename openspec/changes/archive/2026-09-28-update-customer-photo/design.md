## Context

The backend Customer Survey Photos API contract (`/api/v1/sales/customers/:id/photos`) requires multipart form fields:
- `photo`: The binary image file.
- `title`: Short label (string, required, trimmed non-empty).
- `notes`: Additional notes (string, optional).

Responses for both upload and list endpoints provide `title` (string) and `notes` (nullable string). The current Flutter client (`CustomerPhoto` entity, `CustomerPhotoDto`, `CustomerPhotoRepository`, and `CustomerPhotoController`) omits `title` and `notes`, resulting in HTTP 400 rejection during upload and preventing users from viewing photo labels and descriptions.

## Goals / Non-Goals

**Goals:**
- Update `CustomerPhoto` entity to contain `title: String` and `notes: String?`.
- Update `CustomerPhotoDto` to parse `title` (defaulting to `""` for legacy records) and `notes` (nullable), mapping them to `CustomerPhoto`.
- Update `CustomerPhotoRepository` interface and implementation to accept `title` and `notes`, including them in multipart `FormData`.
- Update `CustomerPhotoController.addPhoto` to pass `title` and `notes` to repository.
- Provide a bottom sheet or dialog after photo capture/selection allowing the user to preview the image and input a mandatory `title` and optional `notes`.
- Display photo `title` and `notes` on the photo tiles/cards and within `CustomerPhotoViewer`.
- Prevent initiating upload if customer already reached 5 photos limit.

**Non-Goals:**
- Editing photo `title` or `notes` after upload (the API contract does not support photo metadata modification).
- Multi-photo batch upload in a single request (the backend accepts one photo per request).

## Decisions

### 1. Photo Details Input UI
- **Choice**: Display a modal bottom sheet (`_showUploadDetailsSheet` or dialog) immediately after image selection/capture.
- **Details**:
  - Displays a thumbnail preview of the captured/selected image.
  - A `TextFormField` for "Judul Foto" (required, with client-side trimming validation).
  - A `TextFormField` for "Catatan (Opsional)" (multiline).
  - Action buttons: "Batal" (cancels and discards selection) and "Unggah" (validates and triggers upload).
- **Alternative considered**: Navigating to a full-screen page. Rejected because a bottom sheet maintains survey context in the customer detail view and provides a much smoother user experience.

### 2. Form Data Construction & Trimming
- **Choice**: Trim strings before constructing `FormData`.
- **Details**:
  - Form map always includes `'photo': MultipartFile...` and `'title': title.trim()`.
  - If `notes != null && notes.trim().isNotEmpty`, include `'notes': notes.trim()`. Omit `'notes'` when empty to match backend contract recommendations.

### 3. Entity & DTO Backward Compatibility
- **Choice**: Default `title` to empty string `""` in DTO when null, and keep `notes` nullable (`String?`).
- **Rationale**: Legacy survey photos stored prior to the backend update have empty titles and null notes. Defaulting ensures existing photo records do not cause runtime null-check exceptions.

### 4. 5-Photo Limit UI Handling
- **Choice**: Disable or hide the "Tambah Foto" button when `photos.length >= 5` and display a helper badge `(X / 5 foto)`.
- **Rationale**: Prevents redundant upload attempts, network traffic, and server 400 errors while giving immediate visual feedback on remaining capacity.

## Risks / Trade-offs

- **[Risk] User cancels details dialog after taking photo** → Discard temporary image file and reset picker state cleanly without making network calls.
- **[Risk] Network error or server rejection during upload** → The controller already sets `actionError` and returns UI to normal state, so the rep can easily retry without losing other photos in the list.
