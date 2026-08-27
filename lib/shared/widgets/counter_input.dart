import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class CounterInput extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;

  const CounterInput({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<CounterInput> createState() => _CounterInputState();
}

class _CounterInputState extends State<CounterInput> {
  late double _value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: _formatValue(_value));
  }

  String _formatValue(double value) {
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(double newValue) {
    if (newValue < 0) return;
    setState(() {
      _value = newValue;
      final newText = _formatValue(_value);
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    });
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CounterButton(
          icon: Icons.remove_rounded,
          color: AppColors.err,
          onPressed: () => _updateValue(_value - 1),
        ),
        Expanded(
          child: Container(
            height: 34.0,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            decoration: BoxDecoration(
              color: AppColors.subtle,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: AppRadius.borderSm,
            ),
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.0,
                color: AppColors.text,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val) ?? 0;
                _value = parsed;
                widget.onChanged(_value);
              },
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        _CounterButton(
          icon: Icons.add_rounded,
          color: AppColors.success,
          onPressed: () => _updateValue(_value + 1),
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CounterButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, color: color, size: 16.0),
        ),
      ),
    );
  }
}
