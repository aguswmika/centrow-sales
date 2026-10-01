## Purpose

Lets a sales rep attach, review, and remove photo evidence gathered during a
customer survey, tied to an existing customer record, from within the mobile
app's customer detail screen.

## Requirements

### Requirement: View a customer's survey photos
The system SHALL display all photos attached to the currently selected
customer, ordered oldest-first, in a dedicated "Foto" section of the
customer detail screen, showing each photo thumbnail along with its title and current photo count.

#### Scenario: Customer has photos
- **WHEN** a rep opens the Foto tab for a customer that has one or more
  survey photos
- **THEN** the system displays each photo as a thumbnail with its title, ordered oldest first,
  loaded from the photo's resolved URL, along with the total count against the 5-photo limit

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
with the device camera or selecting it from the device gallery, prompting for a mandatory title and optional notes, and then uploading the photo and metadata to the customer's photo collection.

#### Scenario: Rep chooses a photo source
- **WHEN** a rep taps the add-photo action on the Foto tab
- **THEN** the system presents a choice between "Ambil Foto" (camera) and
  "Pilih dari Galeri" (gallery)

#### Scenario: Rep enters title and notes
- **WHEN** a rep selects or captures a photo
- **THEN** the system displays a confirmation/input dialog showing a preview of the photo with a required "Judul Foto" text field and an optional "Catatan" text field

#### Scenario: Missing or empty title validation
- **WHEN** a rep attempts to submit the upload with an empty or whitespace-only title
- **THEN** the system highlights the validation error and prevents the upload request from being sent

#### Scenario: Successful upload
- **WHEN** a rep provides a valid non-empty title, optional notes, and confirms upload for a supported image under the size limit
- **THEN** the system compresses the photo, uploads it with the title and notes, and appends the newly created photo to the visible list without requiring a manual refresh

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
- **WHEN** a customer already has 5 photos attached
- **THEN** the system disables the add-photo action or warns the rep that the maximum 5 photos limit has been reached

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
pinch-to-zoom, displaying the photo title, notes, and metadata, and allowing the rep to close the view or delete the photo.

#### Scenario: Open full-screen view
- **WHEN** a rep taps a photo thumbnail
- **THEN** the system opens a full-screen view of that photo with pinch-to-zoom, displaying the photo's title, notes (if present), and upload timestamp

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
