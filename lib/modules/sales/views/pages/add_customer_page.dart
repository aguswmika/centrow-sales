import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../app/di.dart';
import '../../../../shared/state/ui_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../controllers/add_customer_controller.dart';
import '../../entities/customer.dart';
import '../widgets/add_customer/add_customer_sidebar.dart';
import '../widgets/add_customer/add_customer_topbar.dart';
import '../widgets/add_customer/step1_identity_form.dart';
import '../widgets/add_customer/step2_locations_form.dart';
import '../widgets/add_customer/step3_contacts_form.dart';

class AddCustomerPage extends StatefulWidget {
  final AddCustomerController? controller;

  const AddCustomerPage({super.key, this.controller});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  late final AddCustomerController _controller;
  void Function()? _cleanupSubscription;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? getIt<AddCustomerController>();
    _controller.loadSegments();

    _cleanupSubscription = _controller.submissionState.subscribe((state) {
      if (!mounted) return;
      if (state is UiSuccess<Customer>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pelanggan "${state.data.name}" berhasil ditambahkan',
            ),
            backgroundColor: AppColors.ok,
          ),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(state.data);
        }
      } else if (state is UiFailure<Customer>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.failure.message),
            backgroundColor: AppColors.err,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _cleanupSubscription?.call();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleNextOrSubmit() {
    if (_controller.currentStep.value == 3) {
      _controller.submit();
    } else {
      final success = _controller.nextStep();
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Harap lengkapi semua bidang bertanda bintang (*) sebelum melanjutkan.',
            ),
            backgroundColor: AppColors.warn,
          ),
        );
      }
    }
  }

  void _handleCancel() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Watch.builder(
          builder: (context) {
            final currentStep = _controller.currentStep.value;
            final isTablet = MediaQuery.sizeOf(context).width >= 900;
            final isLoading = _controller.submissionState.value.isLoading;

            return Column(
              children: [
                AddCustomerTopbar(
                  currentStep: currentStep,
                  onStepChanged: (step) => _controller.setStep(step),
                  onCancel: _handleCancel,
                  onPrev: () => _controller.prevStep(),
                  onNext: _handleNextOrSubmit,
                ),
                if (isLoading)
                  const LinearProgressIndicator(
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
                  ),
                Expanded(
                  child: isTablet
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Form Column (Scrollable)
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(
                                  top: 20.0,
                                  left: 24.0,
                                  right: 24.0,
                                  bottom: 60.0,
                                ),
                                child: _buildCurrentStep(currentStep),
                              ),
                            ),
                            const VerticalDivider(
                              width: 1.5,
                              thickness: 1.5,
                              color: AppColors.border,
                            ),
                            // Right Sidebar Summary Column (280px)
                            SizedBox(
                              width: 280.0,
                              child: AddCustomerSidebar(
                                controller: _controller,
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            left: 16.0,
                            right: 16.0,
                            bottom: 60.0,
                          ),
                          child: _buildCurrentStep(currentStep),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStep(int step) {
    return switch (step) {
      1 => Step1IdentityForm(controller: _controller),
      2 => Step2LocationsForm(controller: _controller),
      3 => Step3ContactsForm(
          controller: _controller,
          onPrev: () => _controller.prevStep(),
          onSubmit: _handleNextOrSubmit,
        ),
      _ => Step1IdentityForm(controller: _controller),
    };
  }
}
