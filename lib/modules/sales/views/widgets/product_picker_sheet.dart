import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/product_controller.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';

class ProductPickerSheet extends StatefulWidget {
  final int? kind;

  const ProductPickerSheet({super.key, this.kind});

  @override
  State<ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<ProductPickerSheet> {
  late final ProductController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = getIt<ProductController>();
    _controller.loadProducts(kind: widget.kind);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final query = value.trim();
    _controller.loadProducts(
      q: query.isNotEmpty ? query : null,
      kind: widget.kind,
    );
  }

  String _formatNumber(double number) {
    final intPart = number.truncate();
    return intPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.rLg),
        ),
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
                  'Pilih Produk / Tenaga Kerja / BBM',
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
              onFieldSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: 'Cari produk berdasarkan nama atau kode...',
                hintStyle: const TextStyle(
                  fontSize: 13.0,
                  color: AppColors.muted,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.sec,
                  size: 20.0,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.brand,
                    size: 20.0,
                  ),
                  onPressed: () => _onSearch(_searchController.text),
                ),
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
                    onRetry: () => _controller.loadProducts(
                      q: _searchController.text.trim().isNotEmpty
                          ? _searchController.text.trim()
                          : null,
                      kind: widget.kind,
                    ),
                  ),
                  UiSuccess(:final data) => _buildProductList(data),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48.0,
                color: AppColors.muted,
              ),
              SizedBox(height: 12.0),
              Text(
                'Tidak ada produk ditemukan',
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
      itemCount: products.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1.0, color: AppColors.border),
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 6.0,
          ),
          title: Text(
            product.name,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (product.code.isNotEmpty)
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
                      product.code,
                      style: const TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sec,
                      ),
                    ),
                  ),
                if (product.uomCode.isNotEmpty)
                  Text(
                    'Satuan: ${product.uomCode}',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: AppColors.sec,
                    ),
                  ),
                if (product.cogs > 0)
                  Text(
                    '• COGS: Rp ${_formatNumber(product.cogs)}',
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brand,
                    ),
                  ),
              ],
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.muted,
          ),
          onTap: () => Navigator.pop(context, product),
        );
      },
    );
  }
}
