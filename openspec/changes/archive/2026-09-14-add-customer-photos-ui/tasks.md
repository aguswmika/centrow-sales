## 1. Dependencies & platform setup

- [x] 1.1 Add `image_picker` to `pubspec.yaml` and verify `flutter pub get` succeeds
- [x] 1.2 Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to `ios/Runner/Info.plist` and verify camera/gallery prompts show real copy on iOS
- [x] 1.3 Add required camera/media permissions to `android/app/src/main/AndroidManifest.xml` and verify camera/gallery pick works on an Android device/emulator
- [x] 1.4 Add `flutter_image_compress` to `pubspec.yaml` and verify `flutter pub get` succeeds

## 2. Entity & DTO

- [x] 2.1 Add `CustomerPhoto` entity (`lib/modules/sales/entities/customer_photo.dart`) with `id`, `url`, `originalName`, `mimeType`, `fileSize`, `createdAt`, `createdBy`, plus a `sizeLabel` display getter, immutable with `==`/`hashCode` matching the style of `CustomerContact`
- [x] 2.2 Add `CustomerPhotoDto` (`lib/modules/sales/repositories/dtos/customer_photo_dto.dart`) with `fromJson` and `toEntity()`, and a list-response DTO wrapping the `items` array per `docs/api/customer-photos.md`
- [x] 2.3 Verify `dart analyze` passes clean on the new entity/DTO files

## 3. Repository

- [x] 3.1 Add `CustomerPhotoRepository` interface + `CustomerPhotoRepositoryImpl` (`lib/modules/sales/repositories/customer_photo_repository.dart`) with `getPhotos(customerId)`, `uploadPhoto(customerId, filePath)`, `deletePhoto(customerId, photoId)`, all returning `Future<Result<T>>`
- [x] 3.2 Implement `uploadPhoto` using `Dio.post` with `FormData`/`MultipartFile.fromFile(filePath, filename: ...)` against `POST /v1/sales/customers/:id/photos`
- [x] 3.3 Implement `getPhotos` against `GET /v1/sales/customers/:id/photos`, mapping the `items` array (empty list when API returns `[]`)
- [x] 3.4 Implement `deletePhoto` against `DELETE /v1/sales/customers/:id/photos/:photoId`
- [x] 3.5 Map Dio errors to `Failure`s using the documented `http_status` codes (400 variants, 401, 403, 404), Bahasa Indonesia messages consistent with `CustomerRepositoryImpl._handleDioError`, not `message` text passthrough
- [x] 3.6 Verify with a manual/dio-mocked check (or unit test if the module has a test harness) that each of the 4xx cases from `docs/api/customer-photos.md` maps to a distinct `Failure`
- [x] 3.7 Modify `uploadPhoto` in `CustomerPhotoRepositoryImpl` to compress the selected/captured file via `flutter_image_compress` (resize to max 1280px longest side, ~70% quality, re-encode to JPEG) before constructing the multipart `FormData`, and verify `dart analyze` passes clean

## 4. Controller

- [x] 4.1 Add `CustomerPhotoController` (`lib/modules/sales/controllers/customer_photo_controller.dart`) with a `photosState` (`ReadonlySignal<UiState<List<CustomerPhoto>>>`), `isUploading` signal, and `loadPhotos(customerId)`, `addPhoto(customerId, filePath)`, `deletePhoto(customerId, photoId)` intents
- [x] 4.2 Ensure `addPhoto` appends the returned photo to current state on success and leaves state untouched on failure (per spec: no placeholder added on error)
- [x] 4.3 Ensure `deletePhoto` only removes the photo from local state after a successful `Ok` result (no optimistic removal, per design.md)
- [x] 4.4 Add `dispose()` disposing all owned signals, matching `CustomerController.dispose()`
- [x] 4.5 Verify `dart analyze` passes clean and controller has no `signals_flutter` import

## 5. Views

- [x] 5.1 Add `CustomerPhotosTab` (`lib/modules/sales/views/widgets/customer_photos_tab.dart`) that resolves `CustomerPhotoController` from `get_it`, loads photos in `initState` for the given `customerId`, and disposes the controller in `dispose`
- [x] 5.2 Render photo grid with `SignalBuilder` wrapping only the reactive grid area, using an exhaustive `switch` over `UiState` (loading/error+retry/success) per `CLAUDE.md` view rules
- [x] 5.3 Add empty-state UI when the success list is empty, distinct from the error state
- [x] 5.4 Add an add-photo action that opens an action sheet ("Ambil Foto" / "Pilih dari Galeri") using `image_picker`'s `ImageSource.camera` / `ImageSource.gallery`, then calls `controller.addPhoto`
- [x] 5.5 Show inline error feedback (file type, file too large, 5-photo limit, permission denied, generic) sourced from the controller's failure state, and a simple upload-in-progress indicator while `isUploading` is true
- [x] 5.6 Add tap-to-open full-screen viewer (`lib/modules/sales/views/widgets/customer_photo_viewer.dart`) with pinch-to-zoom (`InteractiveViewer`), a close action, and a delete action wired to `controller.deletePhoto`
- [x] 5.7 Add delete confirmation prompt (grid and viewer entry points) that only calls `controller.deletePhoto` on explicit confirm
- [x] 5.8 Wire `CustomerPhotosTab` into `CustomerDetailPane` as a 5th tab ("Foto") in `tabTitles` and `_buildActiveTabContent`, passing the selected customer's `id`
- [ ] 5.9 Verify manually in the running app: view photos for a customer with existing photos, empty customer, add via camera, add via gallery, hit the 5-photo limit, delete with confirm and with cancel, open/close full-screen viewer

## 6. Dependency injection

- [x] 6.1 Register `CustomerPhotoRepository` as `registerLazySingleton` and `CustomerPhotoController` as `registerFactory` in `lib/app/di.dart`, following existing registration order (repository before controller)
- [ ] 6.2 Verify `flutter run` boots without a `get_it` resolution error on opening the Foto tab

## 7. Final verification

- [x] 7.1 Run `flutter analyze` and verify it passes clean
- [x] 7.2 Run `dart format .` and verify no formatting diffs remain
- [ ] 7.3 Walk through every scenario in `specs/customer-photos/spec.md` against the running app and confirm each passes
- [ ] 7.4 Manually verify: an uploaded photo is visibly smaller/compressed compared to the original capture, image quality remains legible for survey evidence, and a photo that would have exceeded the server's size limit uncompressed now uploads successfully
