## Purpose

Lets a sales rep attach, review, and remove photo evidence gathered during a
customer survey, tied to an existing customer record, from within the mobile
app's customer detail screen.

## Requirements

### Requirement: View a customer's survey photos
The system SHALL display all photos attached to the currently selected
customer, ordered oldest-first, in a dedicated "Foto" section of the
customer detail screen.

#### Scenario: Customer has photos
- **WHEN** a rep opens the Foto tab for a customer that has one or more
  survey photos
- **THEN** the system displays each photo as a thumbnail, oldest first,
  loaded from the photo's resolved URL

#### Scenario: Customer has no photos
- **WHEN** a rep opens the Foto tab for a customer with zero survey photos
- **THEN** the system displays an empty state inviting the rep to add the
  first photo, rather than an empty grid or an error

#### Scenario: Photo list fails to load
- **WHEN** the photo list request fails (network error or non-2xx response)
- **THEN** the system displays an error state with a retry action, and does
  not show a stale or partial photo list

### Requirement: Add a survey photo
The system SHALL let a rep attach a new photo to a customer by capturing it
with the device camera or selecting it from the device gallery, then
uploading it to the customer's photo collection.

#### Scenario: Rep chooses a photo source
- **WHEN** a rep taps the add-photo action on the Foto tab
- **THEN** the system presents a choice between "Ambil Foto" (camera) and
  "Pilih dari Galeri" (gallery)

#### Scenario: Successful upload
- **WHEN** a rep selects or captures a supported image (JPEG, PNG, or WEBP)
  under the server-configured size limit and the upload completes
  successfully
- **THEN** the system adds the new photo to the top of the visible list (as
  the newest, since the list is oldest-first, it appears at the end) without
  requiring the rep to manually refresh

#### Scenario: Unsupported file type
- **WHEN** a rep selects a file that the server rejects because it is not
  JPEG/PNG/WEBP
- **THEN** the system shows an inline error explaining the file type is not
  supported and does not add a placeholder photo to the list

#### Scenario: File too large
- **WHEN** a rep selects a file that exceeds the server-configured maximum
  size
- **THEN** the system shows an inline error explaining the file is too
  large

#### Scenario: Photo limit reached
- **WHEN** a rep attempts to add a 6th photo to a customer that already has
  5 photos
- **THEN** the system shows an inline error explaining the 5-photo limit has
  been reached and does not attempt the upload request again automatically

#### Scenario: Upload fails for another reason
- **WHEN** the upload request fails due to a network error, an
  authorization error, or the customer no longer existing
- **THEN** the system shows an inline error appropriate to the failure and
  leaves the rep able to retry

### Requirement: Compress a photo before upload
The system SHALL compress a photo client-side (resize and re-encode) before
uploading it, so the file sent to the server is smaller than the original
capture/selection wherever compression reduces its size.

#### Scenario: Photo is compressed before upload
- **WHEN** a rep selects or captures a photo to add
- **THEN** the system compresses it before sending the upload request, and
  the photo that later appears in the grid reflects the uploaded
  (compressed) file, not the original

#### Scenario: Compression lets an otherwise-oversized photo upload successfully
- **WHEN** the original captured/selected photo exceeds the server's
  configured maximum size but the compressed version does not
- **THEN** the upload succeeds using the compressed file

#### Scenario: Compressed photo still exceeds the limit
- **WHEN** the compressed photo still exceeds the server's configured
  maximum size
- **THEN** the system shows the same "file too large" inline error as it
  would for an uncompressed oversized photo

### Requirement: View a photo full-screen
The system SHALL let a rep open any thumbnail in a full-screen view with
pinch-to-zoom, from which the rep can close the view or delete the photo.

#### Scenario: Open full-screen view
- **WHEN** a rep taps a photo thumbnail
- **THEN** the system opens a full-screen view of that photo, supporting
  pinch-to-zoom

#### Scenario: Close full-screen view
- **WHEN** a rep taps the close action while viewing a photo full-screen
- **THEN** the system returns to the Foto tab's grid without altering the
  photo list

### Requirement: Delete a survey photo
The system SHALL let a rep remove a photo from a customer's photo
collection, from the grid or from the full-screen view, after the rep
confirms the deletion.

#### Scenario: Confirmed deletion
- **WHEN** a rep chooses to delete a photo and confirms the action in a
  confirmation prompt
- **THEN** the system removes the photo from the customer's photo
  collection and it no longer appears in the list

#### Scenario: Cancelled deletion
- **WHEN** a rep chooses to delete a photo but dismisses or cancels the
  confirmation prompt
- **THEN** the system leaves the photo in the customer's photo collection
  unchanged

#### Scenario: Delete fails
- **WHEN** the delete request fails (network error, authorization error, or
  the photo no longer exists)
- **THEN** the system shows an inline error and keeps the photo visible in
  the list rather than silently removing it from the UI

### Requirement: Photo actions respect server-side permissions
The system SHALL surface a permission-denied error when the server rejects
an add or delete action because the rep lacks the required permission,
without allowing the local UI state to imply the action succeeded.

#### Scenario: Rep lacks upload permission
- **WHEN** a rep attempts to add a photo and the server responds with a
  permission-denied (403) error
- **THEN** the system shows an inline error indicating the action is not
  permitted and does not add the photo to the list

#### Scenario: Rep lacks delete permission
- **WHEN** a rep attempts to delete a photo and the server responds with a
  permission-denied (403) error
- **THEN** the system shows an inline error indicating the action is not
  permitted and keeps the photo in the list
