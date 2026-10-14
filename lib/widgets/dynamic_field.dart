import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/search_config.dart';

class DynamicField extends StatefulWidget {
  final FieldConfig config;
  final String value;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final VoidCallback? onFieldSubmitted;

  const DynamicField({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  State<DynamicField> createState() => _DynamicFieldState();
}

class _DynamicFieldState extends State<DynamicField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(DynamicField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final formatted = _formatValue(widget.value);
      if (_controller.text != formatted) {
        _controller.text = formatted;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(String val) {
    if (widget.config.type == FieldType.date && val.isNotEmpty) {
      return _formatDateForDisplay(val);
    }
    return val;
  }

  String _formatDateForDisplay(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.config.type) {
      FieldType.text => _buildTextField(context),
      FieldType.date => _buildDateField(context),
      FieldType.dropdown => _buildDropdownField(context),
    };
  }

  Widget _buildTextField(BuildContext context) {
    return TextFormField(
      key: ValueKey('field_${widget.config.key}'),
      controller: _controller,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: widget.config.label,
        hintText: widget.config.placeholder,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      textInputAction: TextInputAction.next,
      onChanged: widget.onChanged,
      onFieldSubmitted: (_) => widget.onFieldSubmitted?.call(),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      key: ValueKey('field_${widget.config.key}'),
      controller: _controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: widget.config.label,
        hintText: widget.config.placeholder,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.value.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                tooltip: 'Clear date',
              ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context),
              tooltip: 'Select date',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('field_${widget.config.key}_${widget.value}'),
      initialValue: widget.value.isNotEmpty ? widget.value : null,
      decoration: InputDecoration(
        labelText: widget.config.label,
        hintText: widget.config.placeholder,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: (widget.config.options ?? [])
          .map(
            (option) =>
                DropdownMenuItem<String>(value: option, child: Text(option)),
          )
          .toList(),
      onChanged: (newValue) => widget.onChanged(newValue ?? ''),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate = widget.value.isNotEmpty
        ? (DateTime.tryParse(widget.value) ?? today)
        : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(today) ? today : initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: 'SELECT DATE (YYYY-MM-DD)',
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      _controller.text = _formatDateForDisplay(formatted);
      widget.onChanged(formatted);
    }
  }
}
