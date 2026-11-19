import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';

class FilterOption<T> {
  final String label;
  final T value;

  const FilterOption({required this.label, required this.value});
}

/// Tombol filter kotak yang membuka bottom sheet berisi daftar opsi.
/// Tetap rapi berapa pun jumlah opsinya (sheet bisa di-scroll).
class AppFilterButton<T> extends StatelessWidget {
  final String title;
  final List<FilterOption<T>> options;
  final T selectedValue;

  /// Nilai "tanpa filter"; tombol diberi penanda saat nilai terpilih berbeda.
  final T defaultValue;
  final ValueChanged<T> onChanged;
  final double size;

  const AppFilterButton({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.defaultValue,
    required this.onChanged,
    this.size = 42.0,
  });

  bool get _isActive => selectedValue != defaultValue;

  Future<void> _open(BuildContext context) async {
    final result = await showModalBottomSheet<FilterOption<T>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet<T>(
        title: title,
        options: options,
        selectedValue: selectedValue,
      ),
    );
    if (result != null) onChanged(result.value);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: title,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: AppRadius.borderMd,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _isActive
                ? AppColors.brand.withValues(alpha: 0.1)
                : AppColors.subtle,
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: _isActive ? AppColors.brand : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 20.0,
                color: _isActive ? AppColors.brand : AppColors.sec,
              ),
              if (_isActive)
                Positioned(
                  top: 7.0,
                  right: 7.0,
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet<T> extends StatelessWidget {
  final String title;
  final List<FilterOption<T>> options;
  final T selectedValue;

  const _FilterSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10.0),
                width: 36.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 8.0),
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            const Divider(height: 1.0, thickness: 1.0, color: AppColors.border),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                itemCount: options.length,
                itemBuilder: (context, i) {
                  final option = options[i];
                  final isSelected = option.value == selectedValue;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 14.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.label,
                              style: GoogleFonts.inter(
                                fontSize: 14.0,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.brand
                                    : AppColors.text,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              size: 20.0,
                              color: AppColors.brand,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
