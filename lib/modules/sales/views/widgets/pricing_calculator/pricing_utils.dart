import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';

String formatRp(double amount) {
  if (amount == 0) return 'Rp 0';
  final isNegative = amount < 0;
  final absAmount = amount.abs();
  final intPart = absAmount.truncate();
  final formattedInt = intPart.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
  return isNegative ? '-Rp $formattedInt' : 'Rp $formattedInt';
}

Widget buildTableHeader(
  List<String> columns, {
  List<int> flexes = const [3, 1, 1, 1, 2, 2],
}) {
  return Container(
    color: AppColors.subtle,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    child: Row(
      children: [
        for (int i = 0; i < flexes.length; i++) ...[
          if (i > 0) SizedBox(width: (i >= flexes.length - 2) ? 16.0 : 8.0),
          Expanded(
            flex: flexes[i],
            child: buildTh(
              columns[i],
              center: i > 0 && i < flexes.length - 2 && flexes[i] == 1,
              right: i >= flexes.length - 2 || (i > 0 && flexes[i] > 1),
            ),
          ),
        ],
        const SizedBox(width: 8.0),
        const SizedBox(width: 30.0),
      ],
    ),
  );
}

Widget buildTh(String text, {bool center = false, bool right = false}) {
  return Text(
    text.toUpperCase(),
    style: GoogleFonts.inter(
      fontSize: 11.0,
      fontWeight: FontWeight.w700,
      color: AppColors.sec,
      letterSpacing: 0.5,
    ),
    textAlign: right
        ? TextAlign.right
        : center
        ? TextAlign.center
        : TextAlign.left,
  );
}

Widget buildInput(
  String initialValue,
  void Function(String) onChanged, {
  bool enabled = true,
}) {
  return Container(
    height: 40.0,
    decoration: BoxDecoration(
      color: enabled
          ? AppColors.subtle
          : AppColors.border.withValues(alpha: 0.3),
      border: Border.all(color: AppColors.border, width: 1.5),
      borderRadius: AppRadius.borderSm,
    ),
    child: TextFormField(
      initialValue: initialValue,
      enabled: enabled,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        color: enabled ? AppColors.text : AppColors.muted,
      ),
      decoration: const InputDecoration(
        filled: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    ),
  );
}

Widget buildTotalAmount(String text) {
  return Text(
    text,
    textAlign: TextAlign.right,
    style: const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
  );
}

Widget buildAddBtn(String text, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 40.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, color: AppColors.brand, size: 16.0),
          const SizedBox(width: 8.0),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: AppColors.brand,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildSumRow(
  String label,
  String value, {
  bool bold = false,
  bool semiBold = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: bold
                ? FontWeight.w700
                : semiBold
                ? FontWeight.w600
                : FontWeight.w500,
            color: bold || semiBold ? AppColors.text : AppColors.sec,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: bold
                ? FontWeight.w800
                : semiBold
                ? FontWeight.w700
                : FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    ),
  );
}
