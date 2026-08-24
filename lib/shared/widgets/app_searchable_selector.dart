import 'dart:async';
import 'package:flutter/material.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';
import 'package:centrow_sales/shared/theme/app_spacing.dart';
import 'package:centrow_sales/shared/theme/app_typography.dart';

class AppSearchableSelector<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final Future<List<T>> Function(String query) onSearch;
  final String Function(T) itemAsString;
  final ValueChanged<T?> onChanged;
  final bool isRequired;
  final bool enabled;

  const AppSearchableSelector({
    super.key,
    this.label,
    this.hint,
    required this.value,
    required this.onSearch,
    required this.itemAsString,
    required this.onChanged,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  State<AppSearchableSelector<T>> createState() =>
      _AppSearchableSelectorState<T>();
}

class _AppSearchableSelectorState<T> extends State<AppSearchableSelector<T>> {
  @override
  Widget build(BuildContext context) {
    final displayValue = widget.value != null
        ? widget.itemAsString(widget.value as T)
        : null;

    final textField = GestureDetector(
      onTap: widget.enabled ? () => _showSearchModal(context) : null,
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: displayValue),
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: const Icon(Icons.search, color: AppColors.sec),
            filled: true,
            fillColor: widget.enabled
                ? AppColors.subtle
                : const Color(0xFFF0F0EC),
            border: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderMd,
              borderSide: BorderSide(color: AppColors.brand, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ),
    );

    if (widget.label == null) return textField;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label!,
          style: AppTypography.bodySm(
            color: AppColors.sec,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.labelGap),
        textField,
      ],
    );
  }

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SearchModal<T>(
        onSearch: widget.onSearch,
        itemAsString: widget.itemAsString,
        onSelected: (item) {
          widget.onChanged(item);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SearchModal<T> extends StatefulWidget {
  final Future<List<T>> Function(String query) onSearch;
  final String Function(T) itemAsString;
  final ValueChanged<T> onSelected;

  const _SearchModal({
    required this.onSearch,
    required this.itemAsString,
    required this.onSelected,
  });

  @override
  State<_SearchModal<T>> createState() => _SearchModalState<T>();
}

class _SearchModalState<T> extends State<_SearchModal<T>> {
  Timer? _debounce;
  List<T> _results = [];
  bool _loading = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _loading = true);
    try {
      final results = await widget.onSearch('');
      if (mounted) {
        setState(() {
          _results = results;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query == _lastQuery) return;
      setState(() {
        _loading = true;
        _lastQuery = query;
      });
      try {
        final results = await widget.onSearch(query);
        setState(() {
          _results = results;
        });
      } finally {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (!_loading && _results.isEmpty)
              const Center(child: Text('No results')),
            if (!_loading && _results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(widget.itemAsString(_results[index])),
                    onTap: () => widget.onSelected(_results[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
