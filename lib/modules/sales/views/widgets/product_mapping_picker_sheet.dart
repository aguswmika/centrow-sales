import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/pc/controllers/product_mapping_controller.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';

class ProductMappingPickerSheet extends StatefulWidget {
  final String treatmentMethodId;

  const ProductMappingPickerSheet({super.key, required this.treatmentMethodId});

  @override
  State<ProductMappingPickerSheet> createState() =>
      _ProductMappingPickerSheetState();
}

class _ProductMappingPickerSheetState extends State<ProductMappingPickerSheet> {
  late final ProductMappingController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = getIt<ProductMappingController>();
    _controller.loadProductMappings(
      treatmentMethodId: widget.treatmentMethodId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final query = value.trim();
    _controller.loadProductMappings(
      treatmentMethodId: widget.treatmentMethodId,
      keyword: query.isNotEmpty ? query : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.rLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Mapping Bahan Kimia',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.sec,
                      size: 20.0,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: _onSearch,
                onFieldSubmitted: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan bahan, hama, atau metode...',
                  hintStyle: const TextStyle(
                    fontSize: 13.0,
                    color: AppColors.muted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.sec,
                    size: 20.0,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: AppColors.muted,
                            size: 18.0,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.subtle,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 10.0,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.brand, width: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8.0),
            const Divider(height: 1.0, color: AppColors.border),

            // Content List
            Expanded(
              child: SignalBuilder(
                builder: (context) {
                  final state = _controller.state.value;
                  return switch (state) {
                    UiInitial() || UiLoading() => const Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    ),
                    UiFailure(:final failure) => ErrorView(
                      message: failure.message,
                      onRetry: () => _controller.loadProductMappings(
                        treatmentMethodId: widget.treatmentMethodId,
                        keyword: _searchController.text.trim().isNotEmpty
                            ? _searchController.text.trim()
                            : null,
                      ),
                    ),
                    UiSuccess(:final data) => _buildMappingList(data),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMappingList(List<ProductMapping> mappings) {
    if (mappings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science_outlined, size: 48.0, color: AppColors.muted),
              SizedBox(height: 12.0),
              Text(
                'Tidak ada mapping produk ditemukan',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sec,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: mappings.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1.0, color: AppColors.border),
      itemBuilder: (context, index) {
        final mapping = mappings[index];
        final doseText = mapping.defaultDose != null
            ? '${mapping.defaultDose} ${mapping.doseUnitCode}'
            : '${mapping.doseMinLimit} - ${mapping.doseMaxLimit} ${mapping.doseUnitCode}';

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          title: Text(
            mapping.productName,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Wrap(
              spacing: 6.0,
              runSpacing: 4.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (mapping.productCode != null &&
                    mapping.productCode!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.subtle,
                      borderRadius: AppRadius.borderSm,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      mapping.productCode!,
                      style: const TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sec,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brand05,
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: AppColors.brand10),
                  ),
                  child: Text(
                    'Hama: ${mapping.pestName}',
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brand,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.subtle,
                    borderRadius: AppRadius.borderSm,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Metode: ${mapping.treatmentMethodName ?? mapping.treatmentMethodCode}',
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                if (mapping.doseUnitCode.isNotEmpty)
                  Text(
                    'Dosis: $doseText',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: AppColors.sec,
                    ),
                  ),
              ],
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.muted,
          ),
          onTap: () => Navigator.pop(context, mapping),
        );
      },
    );
  }
}
