import 'dart:async';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_document_controller.dart';
import 'package:centrow_sales/modules/sales/entities/addendum_template.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_spacing.dart';
import 'package:centrow_sales/shared/theme/app_typography.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';

class AddendumTemplatePickerSheet extends StatefulWidget {
  final ContractAddendumDocumentController? controller;

  const AddendumTemplatePickerSheet({super.key, this.controller});

  static Future<AddendumTemplate?> show(
    BuildContext context, {
    ContractAddendumDocumentController? controller,
  }) {
    return showModalBottomSheet<AddendumTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddendumTemplatePickerSheet(controller: controller),
    );
  }

  @override
  State<AddendumTemplatePickerSheet> createState() =>
      _AddendumTemplatePickerSheetState();
}

class _AddendumTemplatePickerSheetState
    extends State<AddendumTemplatePickerSheet> {
  late final ContractAddendumDocumentController _controller;
  late final bool _isLocalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isLocalController = false;
    } else {
      _controller = getIt<ContractAddendumDocumentController>();
      _isLocalController = true;
    }
    unawaited(_controller.loadActiveTemplates());
  }

  @override
  void dispose() {
    if (_isLocalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
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
              padding: const EdgeInsets.fromLTRB(20.0, 8.0, 12.0, 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Template Addendum',
                          style: AppTypography.heading2(),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Pilih template dokumen untuk mengawali draf dokumen addendum ini.',
                          style: AppTypography.bodySm(color: AppColors.sec),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.sec),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1.0, color: AppColors.border),

            // Content
            Expanded(
              child: SignalBuilder(
                builder: (context) {
                  final state = _controller.templatesState.value;
                  return switch (state) {
                    UiInitial() || UiLoading() => const Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    ),
                    UiFailure(:final failure) => ErrorView(
                      message: failure.message,
                      onRetry: _controller.loadActiveTemplates,
                    ),
                    UiSuccess(:final data) => _buildTemplateList(context, data),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateList(
    BuildContext context,
    List<AddendumTemplate> templates,
  ) {
    if (templates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.subtle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 28,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Belum Ada Template Aktif',
                style: AppTypography.heading3(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Belum ada template addendum aktif yang tersedia. Hubungi administrator.',
                style: AppTypography.bodySm(color: AppColors.sec),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: templates.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1.0, color: AppColors.border),
      itemBuilder: (context, index) {
        final template = templates[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          title: Text(
            template.title,
            style: AppTypography.bodyMd(fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.muted,
          ),
          onTap: () => Navigator.of(context).pop(template),
        );
      },
    );
  }
}
