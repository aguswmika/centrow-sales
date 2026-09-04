import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/toast.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'pricing_calculator/pricing_tabs.dart';
import 'pricing_calculator/pricing_material_tab.dart';
import 'pricing_calculator/pricing_worker_tab.dart';
import 'pricing_calculator/pricing_item_tab.dart';
import 'pricing_calculator/pricing_settings_card.dart';

class PricingCalculatorView extends StatefulWidget {
  final Proposal proposal;
  final PricingCalculatorController calculatorController;

  const PricingCalculatorView({
    super.key,
    required this.proposal,
    required this.calculatorController,
  });

  @override
  State<PricingCalculatorView> createState() => _PricingCalculatorViewState();
}

class _PricingCalculatorViewState extends State<PricingCalculatorView> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PricingTabs(
                activeTab: _activeTab,
                onTabChanged: (index) => setState(() => _activeTab = index),
                controller: widget.calculatorController,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          Container(
                            color: AppColors.surface,
                            child: _buildTabContent(),
                          ),
                          SignalBuilder(
                            builder: (context) {
                              if (widget.calculatorController.previewState.value
                                  is UiLoading) {
                                return const LinearProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.brand,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: PricingSettingsCard(
                          controller: widget.calculatorController,
                        ),
                      ),
                      const SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _PreviewActionBar(
          proposal: widget.proposal,
          controller: widget.calculatorController,
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return PricingMaterialTab(controller: widget.calculatorController);
      case 1:
        return PricingWorkerTab(controller: widget.calculatorController);
      case 2:
        return PricingItemTab(controller: widget.calculatorController);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _PreviewActionBar extends StatelessWidget {
  final Proposal proposal;
  final PricingCalculatorController controller;

  const _PreviewActionBar({required this.proposal, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SignalBuilder(
        builder: (context) {
          final isLoading = controller.previewState.value is UiLoading;
          return AppButton(
            text: 'Lihat Ringkasan',
            isLoading: isLoading,
            icon: const Icon(
              Icons.arrow_forward,
              size: 18,
              color: Colors.white,
            ),
            onPressed: isLoading
                ? null
                : () async {
                    await controller.previewPricing(proposal.id);
                    if (!context.mounted) return;
                    final state = controller.previewState.value;
                    switch (state) {
                      case UiSuccess(:final PricingPreview data):
                        await context.pushNamed(
                          'proposal-pricing-preview',
                          pathParameters: {'id': proposal.id},
                          extra: {
                            'preview': data,
                            'controller': controller,
                            'proposal': proposal,
                            'contractMonths':
                                controller.contractMonths.value ?? 12,
                          },
                        );
                      case UiFailure(:final failure):
                        showAppToast(context, failure.message, isError: true);
                      default:
                        break;
                    }
                  },
          );
        },
      ),
    );
  }
}
