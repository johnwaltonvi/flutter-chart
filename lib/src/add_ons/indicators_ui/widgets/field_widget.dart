import 'package:flutter/material.dart';

/// Field widget
class FieldWidget extends StatelessWidget {
  /// Initializes
  const FieldWidget({
    required this.initialValue,
    this.onValueChanged,
    this.label = '',
    Key? key,
  }) : super(key: key);

  /// Initial value
  final String initialValue;

  /// Will be called whenever the field's value has changed.
  final ValueChanged<String>? onValueChanged;

  /// The label of the field.
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Widget field = TextFormField(
      style: theme.textTheme.bodySmall,
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      onChanged: onValueChanged,
      decoration: InputDecoration(
        labelText: label.isEmpty ? null : label,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth.isFinite) {
          return field;
        }
        return SizedBox(width: 160, child: field);
      },
    );
  }
}
