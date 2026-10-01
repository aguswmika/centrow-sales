## 1. Entity and DTO Layer

- [x] 1.1 Update `CustomerPhoto` entity in `lib/modules/sales/entities/customer_photo.dart` to add `title: String` and `notes: String?`, updating the constructor, `copyWith`, equality operator, `hashCode`, and `toString`. Verify with `flutter analyze`.
- [x] 1.2 Update `CustomerPhotoDto` in `lib/modules/sales/repositories/dtos/customer_photo_dto.dart` to parse `title` (defaulting to empty string if missing) and nullable `notes` from JSON, and map them to `CustomerPhoto` in `toEntity()`. Verify with `flutter analyze`.

## 2. Repository and Controller Layer

- [x] 2.1 Update `CustomerPhotoRepository` interface and `CustomerPhotoRepositoryImpl` in `lib/modules/sales/repositories/customer_photo_repository.dart` to accept `title: String` and `notes: String?` in `uploadPhoto()`, and include `title.trim()` and optional `notes.trim()` in the multipart `FormData`. Verify with `flutter analyze`.
- [x] 2.2 Update `CustomerPhotoController.addPhoto` in `lib/modules/sales/controllers/customer_photo_controller.dart` to accept `title: String` and `notes: String?`, forwarding them to `uploadPhoto`. Verify with `flutter analyze`.

## 3. UI Layer

- [x] 3.1 Create a photo details bottom sheet/dialog in `lib/modules/sales/views/widgets/customer_photos_tab.dart` showing a preview of the selected photo, a mandatory "Judul Foto" text field with validation, and an optional "Catatan" text field before upload confirmation.
- [x] 3.2 Update `CustomerPhotosTab` in `lib/modules/sales/views/widgets/customer_photos_tab.dart` to display photo titles on the thumbnails, show photo counter against the 5-photo limit, and prevent adding more when the limit of 5 is reached.
- [x] 3.3 Update `CustomerPhotoViewer` in `lib/modules/sales/views/widgets/customer_photo_viewer.dart` to show photo title, notes, and metadata info overlay in full-screen view.

## 4. Verification

- [x] 4.1 Run `rtk flutter analyze` and confirm zero static analysis errors across all modified modules.
