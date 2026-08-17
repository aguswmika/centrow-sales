import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../app/di.dart';
import '../../../../shared/state/ui_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../controllers/customer_controller.dart';
import '../widgets/customer_detail_pane.dart';
import '../widgets/customer_master_list.dart';

class CustomerPage extends StatefulWidget {
  final CustomerController? controller;

  const CustomerPage({super.key, this.controller});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late final CustomerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? getIt<CustomerController>();
    if (widget.controller == null) {
      _controller.loadCustomers();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Watch.builder(
          builder: (context) {
            final state = _controller.customersState.value;

            return switch (state) {
              UiInitial() || UiLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.brand),
              ),
              UiFailure(:final failure) => ErrorView(
                message: failure.message,
                onRetry: _controller.loadCustomers,
              ),
              UiSuccess() => _buildSplitContent(context),
            };
          },
        ),
      ),
    );
  }

  Widget _buildSplitContent(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 720;
    final customers = _controller.filteredCustomers.value;
    final selectedCust = _controller.selectedCustomer.value;
    final selectedId = selectedCust?.id ?? '';
    final selectedSeg = _controller.selectedSegment.value;
    final query = _controller.searchQuery.value;
    final activeTab = _controller.activeDetailTab.value;

    final masterList = CustomerMasterList(
      customers: customers,
      selectedCustomerId: selectedId,
      selectedSegment: selectedSeg,
      searchQuery: query,
      onSelectCustomer: _controller.selectCustomer,
      onSelectSegment: _controller.selectSegment,
      onSearchChanged: _controller.setSearchQuery,
      onAddCustomer: () {},
    );

    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 360.0, child: masterList),
          const VerticalDivider(
            width: 1.5,
            thickness: 1.5,
            color: AppColors.border,
          ),
          Expanded(
            child: CustomerDetailPane(
              customer: selectedCust,
              activeTab: activeTab,
              onTabChanged: _controller.setDetailTab,
              onAddProposal: () {},
              onEditData: () {},
            ),
          ),
        ],
      );
    }

    return masterList;
  }
}
