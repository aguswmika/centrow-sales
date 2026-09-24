import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/theme/app_typography.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/toast.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_controller.dart';

class ContractAddendumFormSheet extends StatefulWidget {
  final Contract contract;
  final ContractAddendumController? controller;

  const ContractAddendumFormSheet({
    super.key,
    required this.contract,
    this.controller,
  });

  @override
  State<ContractAddendumFormSheet> createState() =>
      _ContractAddendumFormSheetState();
}

class _ContractAddendumFormSheetState extends State<ContractAddendumFormSheet> {
  late final ContractAddendumController _controller;
  late final TextEditingController _deltaCtrl;
  late final TextEditingController _reasonCtrl;

  int _delta = 0;
  String? _clientError;
  String? _serverError;
  bool _isSubmitting = false;

  int get _currentVisits => widget.contract.totalVisits ?? 0;
  int get _newTotalVisits => _currentVisits + _delta;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? getIt<ContractAddendumController>();
    _deltaCtrl = TextEditingController(text: '');
    _reasonCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _deltaCtrl.dispose();
    _reasonCtrl.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onDeltaChanged(String val) {
    setState(() {
      _serverError = null;
      final trimmed = val.trim();
      if (trimmed.isEmpty || trimmed == '+' || trimmed == '-') {
        _delta = 0;
      } else {
        _delta = int.tryParse(trimmed) ?? 0;
      }
      _validate();
    });
  }

  void _adjustDelta(int step) {
    setState(() {
      _serverError = null;
      _delta += step;
      _deltaCtrl.text = _delta > 0 ? '+$_delta' : '$_delta';
      _validate();
    });
  }

  bool _validate() {
    if (_delta == 0) {
      _clientError = 'Perubahan kunjungan tidak boleh 0';
      return false;
    }
    if (_newTotalVisits <= 0) {
      _clientError = 'Total kunjungan baru harus lebih dari 0';
      return false;
    }
    _clientError = null;
    return true;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _serverError = null;
    });

    final reason = _reasonCtrl.text.trim();
    final result = await _controller.createAddendum(
      widget.contract.id,
      visitDelta: _delta,
      reason: reason.isNotEmpty ? reason : null,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    switch (result) {
      case Ok():
        Navigator.of(context).pop(true);
      case Err(:final failure):
        setState(() {
          _serverError = failure.message;
        });
        showAppToast(context, failure.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
            left: 24.0,
            right: 24.0,
            top: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Buat Addendum Kontrak',
                    style: AppTypography.heading2(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.sec),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.contract.code} · ${widget.contract.customerName}',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Calculation Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kunjungan Saat Ini',
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          '$_currentVisits kunjungan',
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Perubahan Kunjungan (Delta)',
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            color: AppColors.muted,
                          ),
                        ),
                        Text(
                          _delta > 0
                              ? '+$_delta kunjungan'
                              : '$_delta kunjungan',
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: _delta > 0
                                ? AppColors.ok
                                : (_delta < 0 ? AppColors.err : AppColors.text),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20.0, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Kunjungan Baru',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          '$_newTotalVisits kunjungan',
                          style: GoogleFonts.inter(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w800,
                            color: _newTotalVisits > 0
                                ? AppColors.brand
                                : AppColors.err,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Visit Delta Input
              Text(
                'Perubahan Kunjungan (Delta) *',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6.0),
              Row(
                children: [
                  _DeltaQuickButton(
                    label: '-5',
                    onPressed: () => _adjustDelta(-5),
                  ),
                  const SizedBox(width: 6.0),
                  _DeltaQuickButton(
                    label: '-1',
                    onPressed: () => _adjustDelta(-1),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: _deltaCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: false,
                      ),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                      decoration: InputDecoration(
                        hintText: '0 (cth: +2 atau -1)',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13.0,
                          color: AppColors.muted,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 12.0,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: AppRadius.borderMd,
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.borderMd,
                          borderSide: BorderSide(
                            color: _clientError != null
                                ? AppColors.err
                                : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.borderMd,
                          borderSide: BorderSide(
                            color: _clientError != null
                                ? AppColors.err
                                : AppColors.brand,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: _onDeltaChanged,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  _DeltaQuickButton(
                    label: '+1',
                    onPressed: () => _adjustDelta(1),
                  ),
                  const SizedBox(width: 6.0),
                  _DeltaQuickButton(
                    label: '+5',
                    onPressed: () => _adjustDelta(5),
                  ),
                ],
              ),
              if (_clientError != null) ...[
                const SizedBox(height: 6.0),
                Text(
                  _clientError!,
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: AppColors.err,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 16.0),

              // Reason Input
              Text(
                'Alasan Perubahan (Opsional)',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6.0),
              TextField(
                controller: _reasonCtrl,
                maxLines: 3,
                style: GoogleFonts.inter(fontSize: 14.0, color: AppColors.text),
                decoration: InputDecoration(
                  hintText:
                      'Contoh: Penambahan frekuensi kunjungan atas permintaan pelanggan...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13.0,
                    color: AppColors.muted,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              if (_serverError != null) ...[
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.err.withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(
                      color: AppColors.err.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.err,
                        size: 18.0,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _serverError!,
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            color: AppColors.err,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24.0),

              // Submit Button
              AppButton(
                text: 'Simpan Addendum',
                height: 46.0,
                isLoading: _isSubmitting,
                borderRadius: AppRadius.borderMd,
                icon: const Icon(
                  Icons.save_outlined,
                  size: 18.0,
                  color: Colors.white,
                ),
                onPressed: _isSubmitting ? null : _submit,
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeltaQuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DeltaQuickButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: AppRadius.borderMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }
}
