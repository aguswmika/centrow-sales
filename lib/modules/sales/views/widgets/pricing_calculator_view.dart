import 'package:flutter/material.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'pricing_calculator/pricing_tabs.dart';
import 'pricing_calculator/pricing_material_tab.dart';
import 'pricing_calculator/pricing_worker_tab.dart';
import 'pricing_calculator/pricing_item_tab.dart';
import 'pricing_calculator/pricing_cogs_card.dart';
import 'pricing_calculator/pricing_margin_card.dart';
import 'pricing_calculator/pricing_bottom_bar.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;

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
                          Container(
                            color: AppColors.surface,
                            child: _buildTabContent(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: isNarrow
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      PricingCogsCard(
                                        controller: widget.calculatorController,
                                      ),
                                      const SizedBox(height: 16.0),
                                      PricingMarginCard(
                                        controller: widget.calculatorController,
                                      ),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: PricingCogsCard(
                                          controller:
                                              widget.calculatorController,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: PricingMarginCard(
                                          controller:
                                              widget.calculatorController,
                                        ),
                                      ),
                                    ],
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
            PricingBottomBar(
              proposal: widget.proposal,
              controller: widget.calculatorController,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return PricingMaterialTab(controller: widget.calculatorController);
      case 1:
        return PricingWokerTab(controller: widget.calculatorController);
      case 2:
        return PricingItemTab(controller: widget.calculatorController);
      default:
        return const SizedBox.shrink();
    }
  }
}
