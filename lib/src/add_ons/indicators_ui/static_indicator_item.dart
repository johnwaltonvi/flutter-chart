import 'package:flutter/material.dart';

import 'indicator_config.dart';
import 'indicator_item.dart';

/// Minimal item for indicators that only support remove/inspect actions.
class StaticIndicatorItem extends IndicatorItem {
  /// Initializes the indicator item.
  const StaticIndicatorItem({
    required super.title,
    required super.config,
    required super.updateIndicator,
    required super.deleteIndicator,
    this.description,
    super.key,
  });

  /// Optional helper text shown in the edit dialog.
  final String? description;

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      _StaticIndicatorItemState();
}

class _StaticIndicatorItemState extends IndicatorItemState<IndicatorConfig> {
  @override
  IndicatorConfig updateIndicatorConfig() => widget.config;

  @override
  Widget getIndicatorOptions() {
    final item = widget as StaticIndicatorItem;
    final description = item.description;
    if (description == null || description.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      description,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
