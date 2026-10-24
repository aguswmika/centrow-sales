import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:centrow_sales/modules/sales/controllers/richtext_image_controller.dart';
import 'package:centrow_sales/modules/sales/entities/richtext_image.dart';

class RichtextImageGallerySheet extends StatefulWidget {
  final ValueChanged<RichtextImage> onSelected;

  const RichtextImageGallerySheet({super.key, required this.onSelected});

  @override
  State<RichtextImageGallerySheet> createState() =>
      _RichtextImageGallerySheetState();
}

class _RichtextImageGallerySheetState extends State<RichtextImageGallerySheet> {
  late final RichtextImageController _controller =
      getIt<RichtextImageController>();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.loadImages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(source: source);
      if (picked == null || !mounted) return;
      final uploaded = await _controller.uploadImage(picked.path);
      if (uploaded != null && mounted) {
        widget.onSelected(uploaded);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.radiusXl,
          topRight: AppRadius.radiusXl,
        ),
      ),
      builder: (sourceContext) => SafeArea(
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
                  Navigator.of(sourceContext).pop();
                  _pickAndUpload(ImageSource.camera);
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
                  Navigator.of(sourceContext).pop();
                  _pickAndUpload(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(RichtextImage image) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Hapus Gambar',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          content: Text(
            'Hapus "${image.originalName}" secara permanen? Dokumen dan template yang memakai gambar ini akan kehilangan gambarnya.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.sec),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
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
                Navigator.of(dialogContext).pop();
                _controller.deleteImage(image.id);
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

  Widget _buildTile(RichtextImage image) {
    return GestureDetector(
      onTap: () => widget.onSelected(image),
      child: ClipRRect(
        borderRadius: AppRadius.borderMd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.subtle,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.muted,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _showDeleteConfirmation(image),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0x99000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Galeri Gambar',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  SignalBuilder(
                    builder: (context) {
                      final uploading = _controller.isUploading.value;
                      return TextButton.icon(
                        onPressed: uploading ? null : _showSourceSheet,
                        icon: uploading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.upload_outlined, size: 18),
                        label: Text(
                          uploading ? 'Mengunggah...' : 'Unggah',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Cari nama gambar',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                onSubmitted: (value) => _controller.loadImages(keyword: value),
              ),
              SignalBuilder(
                builder: (context) {
                  final error = _controller.actionError.value;
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.err,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.err,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _controller.clearActionError,
                          icon: const Icon(Icons.close, size: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SignalBuilder(
                  builder: (context) {
                    return switch (_controller.imagesState.value) {
                      UiInitial() || UiLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      UiFailure(:final failure) => ErrorView(
                        message: failure.message,
                        onRetry: () => _controller.loadImages(
                          keyword: _searchController.text,
                        ),
                      ),
                      UiSuccess(:final data) =>
                        data.isEmpty
                            ? Center(
                                child: Text(
                                  'Belum ada gambar.',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.sec,
                                  ),
                                ),
                              )
                            : _buildGrid(data),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<RichtextImage> images) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) => _buildTile(images[index]),
          ),
        ),
        SignalBuilder(
          builder: (context) {
            if (!_controller.hasMore.value) return const SizedBox.shrink();
            final loading = _controller.isLoadingMore.value;
            return TextButton(
              onPressed: loading ? null : _controller.loadMore,
              child: Text(loading ? 'Memuat...' : 'Muat lebih banyak'),
            );
          },
        ),
      ],
    );
  }
}
