import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator/pricing_utils.dart';

void main() {
  group('formatCurrencyNumber', () {
    test('formats zero correctly', () {
      expect(formatCurrencyNumber(0), '0');
    });

    test('formats integer amounts without prefix', () {
      expect(formatCurrencyNumber(1000), '1.000');
      expect(formatCurrencyNumber(500000), '500.000');
      expect(formatCurrencyNumber(12500000), '12.500.000');
    });

    test('formats negative amounts', () {
      expect(formatCurrencyNumber(-1500000), '-1.500.000');
    });
  });

  group('CurrencyInputFormatter', () {
    late CurrencyInputFormatter formatter;

    setUp(() {
      formatter = CurrencyInputFormatter();
    });

    test('formats digits into thousand separator format', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '1000000',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );

      expect(result.text, '1.000.000');
      expect(result.selection.baseOffset, 9);
    });

    test('handles empty input', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '1.000',
          selection: TextSelection.collapsed(offset: 5),
        ),
        TextEditingValue.empty,
      );

      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('removes non-digits and formats', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: 'abc500000xyz',
          selection: TextSelection.collapsed(offset: 12),
        ),
      );

      expect(result.text, '500.000');
    });

    test('handles backspace on dot separator gracefully', () {
      // User has '1.000' (cursor after dot: offset 2), presses backspace deleting dot
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '1.000',
          selection: TextSelection.collapsed(offset: 2),
        ),
        const TextEditingValue(
          text: '1000',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );

      // Deleting the separator removes the preceding digit
      expect(result.text, '0');
    });

    test('handles inserting digits in middle of formatted text', () {
      // '10.000', cursor between 10 and dot: offset 2. User inserts 5 -> '105.000'
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '10.000',
          selection: TextSelection.collapsed(offset: 2),
        ),
        const TextEditingValue(
          text: '105.000',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );

      expect(result.text, '105.000');
      expect(result.selection.baseOffset, 3);
    });
  });
}
