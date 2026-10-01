import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_photo_controller.dart';
import 'package:centrow_sales/modules/sales/entities/customer_photo.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_photo_viewer.dart';

class CustomerPhotosTab extends StatefulWidget {
  final String customerId;

  const CustomerPhotosTab({super.key, required this.customerId});

  @override
  State<CustomerPhotosTab> createState() => _CustomerPhotosTabState();
}

class _CustomerPhotosTabState extends State<CustomerPhotosTab> {
  late final CustomerPhotoController _controller =
      getIt<CustomerPhotoController>();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller.loadPhotos(widget.customerId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Error banner
        SignalBuilder(
          builder: (context) {
            final error = _controller.actionError.value;
            if (error == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x1AEF4444),
                border: Border.all(color: AppColors.err, width: 1),
                borderRadius: AppRadius.borderMd,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.err,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    onPressed: _controller.clearActionError,
                  ),
                ],
              ),
            );
          },
        ),
        // Upload progress indicator
        SignalBuilder(
          builder: (context) {
            if (!_controller.isUploading.value) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mengunggah foto...',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    minHeight: 4,
                    color: AppColors.brand,
                    backgroundColor: AppColors.subtle,
                  ),
                ],
              ),
            );
          },
        ),
        // Photo grid
        SignalBuilder(
          builder: (context) {
            final state = _controller.photosState.value;
            return switch (state) {
              UiInitial() || UiLoading() => const SizedBox(
                height: 280,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.brand),
                ),
              ),
              UiFailure(:final failure) => SizedBox(
                height: 280,
                child: ErrorView(
                  message: failure.message,
                  onRetry: () => _controller.loadPhotos(widget.customerId),
                ),
              ),
              UiSuccess(:final data) =>
                data.isEmpty ? _buildEmptyState() : _buildPhotoGrid(data),
            };
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(
              color: AppColors.brand10,
              borderRadius: AppRadius.borderPill,
              border: Border.fromBorderSide(
                BorderSide(color: Color(0x331E40AF)),
              ),
            ),
            child: Text(
              '0/5 Foto',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.brand,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.image, size: 56, color: AppColors.muted),
          const SizedBox(height: 16),
          Text(
            'Belum ada foto',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan foto survey pelanggan dari kamera atau galeri',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.sec),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showImageSourceActionSheet,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Tambah Foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<CustomerPhoto> photos) {
    final isMaxReached = photos.length >= 5;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Foto Survey',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isMaxReached
                      ? AppColors.err.withValues(alpha: 0.1)
                      : AppColors.brand10,
                  borderRadius: AppRadius.borderPill,
                  border: Border.all(
                    color: isMaxReached
                        ? AppColors.err
                        : const Color(0x331E40AF),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${photos.length}/5 Foto',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isMaxReached ? AppColors.err : AppColors.brand,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return _buildPhotoTile(photo);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: isMaxReached ? null : _showImageSourceActionSheet,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(
              isMaxReached ? 'Batas Maksimal 5 Foto Tercapai' : 'Tambah Foto',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isMaxReached
                  ? AppColors.subtle
                  : AppColors.brand,
              foregroundColor: isMaxReached ? AppColors.muted : Colors.white,
              disabledBackgroundColor: AppColors.subtle,
              disabledForegroundColor: AppColors.muted,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(CustomerPhoto photo) {
    final displayTitle = photo.title.trim().isNotEmpty
        ? photo.title.trim()
        : '(Tanpa Judul)';

    return Stack(
      key: ValueKey(photo.id),
      fit: StackFit.expand,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.borderMd,
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => CustomerPhotoViewer(
                    photo: photo,
                    onDelete: () =>
                        _controller.deletePhoto(widget.customerId, photo.id),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.subtle,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: ClipRRect(
                borderRadius: AppRadius.borderMd,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      photo.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.muted,
                            size: 32,
                          ),
                        );
                      },
                    ),
                    if (displayTitle.isNotEmpty)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                          child: Text(
                            displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _showDeleteConfirmation(photo),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.err.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceActionSheet() {
    final state = _controller.photosState.value;
    if (state is UiSuccess<List<CustomerPhoto>> && state.data.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal 5 foto telah tercapai'),
          backgroundColor: AppColors.err,
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.radiusXl,
          topRight: AppRadius.radiusXl,
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.brand,
                ),
                title: Text(
                  'Ambil Foto',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.brand,
                ),
                title: Text(
                  'Pilih dari Galeri',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoUploadSheet(BuildContext context, String filePath) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.radiusXl,
          topRight: AppRadius.radiusXl,
        ),
      ),
      builder: (bottomSheetContext) => _PhotoUploadSheet(
        filePath: filePath,
        onUpload: (title, notes) {
          _controller.addPhoto(
            widget.customerId,
            filePath,
            title: title,
            notes: notes,
          );
        },
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null && mounted) {
        _showPhotoUploadSheet(context, pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null && mounted) {
        _showPhotoUploadSheet(context, pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showDeleteConfirmation(CustomerPhoto photo) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final photoLabel = photo.title.trim().isNotEmpty
            ? '"${photo.title.trim()}"'
            : 'foto ini';
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Hapus Foto',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          content: Text(
            'Hapus $photoLabel secara permanen?',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.sec),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.deletePhoto(widget.customerId, photo.id);
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.err,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PhotoUploadSheet extends StatefulWidget {
  final String filePath;
  final void Function(String title, String? notes) onUpload;

  const _PhotoUploadSheet({required this.filePath, required this.onUpload});

  @override
  State<_PhotoUploadSheet> createState() => _PhotoUploadSheetState();
}

class _PhotoUploadSheetState extends State<_PhotoUploadSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      Navigator.of(context).pop();
      widget.onUpload(title, notes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.borderPill,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Detail Foto',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: AppRadius.borderMd,
                child: Image.file(
                  File(widget.filePath),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: AppColors.subtle,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.muted,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Judul Foto',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Masukkan judul foto',
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.muted),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.brand, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.err),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.err, width: 1.5),
                  ),
                ),
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.text),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul foto wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Catatan (Opsional)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan jika diperlukan...',
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.muted),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.brand, width: 1.5),
                  ),
                ),
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.text),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.sec,
                        side: const BorderSide(color: AppColors.border),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Unggah',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
