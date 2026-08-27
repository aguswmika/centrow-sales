import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/pc/controllers/treatment_method_controller.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';

class TreatmentMethodPickerSheet extends StatefulWidget {
  const TreatmentMethodPickerSheet({super.key});

  @override
  State<TreatmentMethodPickerSheet> createState() =>
      _TreatmentMethodPickerSheetState();
}

class _TreatmentMethodPickerSheetState
    extends State<TreatmentMethodPickerSheet> {
  late final TreatmentMethodController _controller;

  @override
  void initState() {
    super.initState();
    _controller = getIt<TreatmentMethodController>();
    _controller.loadTreatmentMethods();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                    'Pilih Metode Treatment',
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
                      onRetry: _controller.loadTreatmentMethods,
                    ),
                    UiSuccess(:final data) => _buildMethodList(data),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodList(List<TreatmentMethod> methods) {
    if (methods.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science_outlined, size: 48.0, color: AppColors.muted),
              SizedBox(height: 12.0),
              Text(
                'Tidak ada metode treatment ditemukan',
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
      itemCount: methods.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1.0, color: AppColors.border),
      itemBuilder: (context, index) {
        final method = methods[index];
        final hasSubtitle =
            method.code.isNotEmpty ||
            (method.description != null && method.description!.isNotEmpty);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          title: Text(
            method.name,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          subtitle: hasSubtitle
              ? Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (method.code.isNotEmpty)
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
                            method.code,
                            style: const TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.sec,
                            ),
                          ),
                        ),
                      if (method.description != null &&
                          method.description!.isNotEmpty)
                        Text(
                          method.description!,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: AppColors.sec,
                          ),
                        ),
                    ],
                  ),
                )
              : null,
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.muted,
          ),
          onTap: () => Navigator.pop(context, method),
        );
      },
    );
  }
}
