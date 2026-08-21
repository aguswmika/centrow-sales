import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/customer_form_sidebar.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/customer_form_topbar.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/step1_identity_form.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/step2_locations_form.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/step3_contacts_form.dart';

class CustomerFormPage extends StatefulWidget {
  final CustomerFormController? controller;
  final String? customerId;

  const CustomerFormPage({super.key, this.controller, this.customerId});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  late final CustomerFormController _controller;
  void Function()? _cleanupSubscription;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? getIt<CustomerFormController>();
    _controller.loadSegments();
    if (widget.customerId != null) {
      _controller.loadInitialData(widget.customerId!);
    }

    _cleanupSubscription = _controller.submissionState.subscribe((state) {
      if (!mounted) return;
      if (state is UiSuccess<Customer>) {
        final actionText = _controller.customerId.value != null
            ? 'berhasil diperbarui'
            : 'berhasil ditambahkan';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pelanggan "${state.data.name}" $actionText',
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

  void _handleSubmit() {
    _controller.submit();
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
                CustomerFormTopbar(
                  controller: _controller,
                  currentStep: currentStep,
                  onStepChanged: (step) => _controller.setStep(step),
                  onCancel: _handleCancel,
                  onPrev: () => _controller.prevStep(),
                  onNext: _handleNextOrSubmit,
                  isEditMode: _controller.customerId.value != null,
                  onSubmit: _handleSubmit,
                ),
                if (isLoading)
                  const LinearProgressIndicator(
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
                  ),
                if (_controller.isLoadingData.value)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    ),
                  )
                else
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
                                child: CustomerFormSidebar(
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
