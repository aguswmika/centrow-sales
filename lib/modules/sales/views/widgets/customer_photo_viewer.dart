import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/modules/sales/entities/customer_photo.dart';

class CustomerPhotoViewer extends StatefulWidget {
  final CustomerPhoto photo;
  final VoidCallback onDelete;

  const CustomerPhotoViewer({
    super.key,
    required this.photo,
    required this.onDelete,
  });

  @override
  State<CustomerPhotoViewer> createState() => _CustomerPhotoViewerState();
}

class _CustomerPhotoViewerState extends State<CustomerPhotoViewer> {
  String _formatDate(String isoString) {
    if (isoString.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final month = (dt.month >= 1 && dt.month <= 12)
          ? months[dt.month - 1]
          : dt.month.toString();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $month ${dt.year}, $hour:$minute';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(widget.photo.createdAt);
    final displayTitle = widget.photo.title.trim().isNotEmpty
        ? widget.photo.title.trim()
        : '(Tanpa Judul)';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.err),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            widget.photo.url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.brand,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 56,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat foto',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black.withValues(alpha: 0.95),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayTitle,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (widget.photo.notes != null &&
                  widget.photo.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.photo.notes!.trim(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  if (formattedDate.isNotEmpty) ...[
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Icon(
                    Icons.insert_drive_file_outlined,
                    size: 13,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.photo.sizeLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[400],
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

  void _showDeleteConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final photoLabel = widget.photo.title.trim().isNotEmpty
            ? '"${widget.photo.title.trim()}"'
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
                Navigator.of(context).pop(); // Close dialog
                widget.onDelete();
                Navigator.of(context).pop(); // Close viewer
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
